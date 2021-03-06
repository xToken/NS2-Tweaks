// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\Shared\PlayerSpawnAdjustments.lua
// - Dragon

Script.Load("lua/Class.lua")

//This shouldnt really be done this way, but its an effective test.  With a network message it may not arrive at the same time as the rest of the respawn, 
//causing some unnatural feeling for the client.  Probably should be a networked field in the player entity.
//Really there is probably no reason to set angles on respawn, unless its a specific event - returning to RR, round start to face CC etc.
//General respawns will have the client updating the view angles on its next frame, making it sorta pointless.  This would require re-working some of the spawn code a bit.
local kOverrideSpawnAnglesMessage =
{
    viewYaw         = "angle",
    viewPitch       = "angle",
}

function BuildOverrideSpawnAnglesMessage( angles )

    local a = {}
    a.viewYaw = angles.yaw
    a.viewPitch = angles.pitch
    return a

end

Shared.RegisterNetworkMessage( "OverrideSpawnAngles", kOverrideSpawnAnglesMessage )

if Server then

	function SpawnPlayerAtPoint(player, origin, angles)

		player:SetOrigin(origin)
		
		if angles then
			Server.SendNetworkMessage(player, "OverrideSpawnAngles", BuildOverrideSpawnAnglesMessage(angles), true)
		end        
		
	end
	
	local originalPlayingTeamRespawnPlayer
	originalPlayingTeamRespawnPlayer = Class_ReplaceMethod("PlayingTeam", "RespawnPlayer",
		function(self, player, origin, angles)
			local success = false
			local initialTechPoint = Shared.GetEntity(self.initialTechPointId)
			
			if origin then
				//If we were provided valid origin already, pass it along.  Discard angles as we dont care unless its facing the TP for initial join, or RR spawn using fixed points.
				success = Team.RespawnPlayer(self, player, origin)
			elseif initialTechPoint then
			
				// Compute random spawn location
				local capsuleHeight, capsuleRadius = player:GetTraceCapsule()
				local spawnOrigin = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, initialTechPoint:GetOrigin(), 2, 15, EntityFilterAll())
				
				if not spawnOrigin then
					spawnOrigin = initialTechPoint:GetOrigin() + Vector(2, 0.2, 2)
				end
				
				// Orient player towards tech point
				// 5 Meters above TP is alot, lets try 1.
				local lookAtPoint = initialTechPoint:GetOrigin() + Vector(0, 1, 0)
				local toTechPoint = GetNormalizedVector(lookAtPoint - spawnOrigin)
				success = Team.RespawnPlayer(self, player, spawnOrigin, Angles(GetPitchFromVector(toTechPoint), GetYawFromVector(toTechPoint), 0))
				
			else
				Print("PlayingTeam:RespawnPlayer(): No initial tech point.")
			end
			
			return success
			
		end
	)
	
	local originalTeamRespawnPlayer
	originalPlayingTeamRespawnPlayer = Class_ReplaceMethod("Team", "RespawnPlayer",
		function(self, player, origin, angles)

			assert(self:GetIsPlayerOnTeam(player), "Player isn't on team!")
			
			if origin == nil then
				//Only care if origin is invalid.
				// Randomly choose unobstructed spawn points to respawn the player
				local spawnPoint = nil
				local spawnPoints = Server.readyRoomSpawnList
				local numSpawnPoints = table.maxn(spawnPoints)
				
				if numSpawnPoints > 0 then
				
					local spawnPoint = GetRandomClearSpawnPoint(player, spawnPoints)
					if spawnPoint ~= nil then
					
						origin = spawnPoint:GetOrigin()
						angles = spawnPoint:GetAngles()
						
					end
					
				end
				
			end
			
			// Move origin up and drop it to floor to prevent stuck issues with floating errors or slightly misplaced spawns
			if origin then
			
				SpawnPlayerAtPoint(player, origin, angles)
				
				player:ClearEffects()
				
				return true
				
			else
				DebugPrint("Team:RespawnPlayer(player, %s, %s) - Must specify origin.", ToString(origin), ToString(angles))
			end
			
			return false
			
		end
	)

end

if Client then

	//Pitch is stored client side as +/- 1/2 pi in the 'move'.  'Pitch' from the server is networked as 0-2pi (ish?)
	function CorrectViewPitch(pitch)

		if pitch > math.pi then
			pitch = pitch - (2 * math.pi)
		end
		return pitch

	end

	function OnCommandOverrideSpawnAngles(msg)
		if msg then
			Client.SetYaw(msg.viewYaw)
            Client.SetPitch(CorrectViewPitch(msg.viewPitch))
		end
	end
	
	Client.HookNetworkMessage("OverrideSpawnAngles", OnCommandOverrideSpawnAngles)
	
	local kFlashyViewAngleDebugging = false
	local oldCameraHolderMixinSetViewAngles = CameraHolderMixin.SetViewAngles
	function CameraHolderMixin:SetViewAngles(viewAngles)
		oldCameraHolderMixinSetViewAngles(self, viewAngles)
		if kFlashyViewAngleDebugging then
			if self.printViewAngles == nil or self.printViewAngles < Shared.GetTime() then
				Print(string.format("Player has pitch %s.", ToString(self.viewPitch)))
				local cs = Script.CallStack()
				if not string.match(cs, "OnProcessIntermediate") then
					//We reset when OnProcessMove calls this.
					Print("Called from OnProcessMove")
					self.printViewAngles = Shared.GetTime() + 1
				else
					Print("Called from OnProcessIntermediate")
				end
			end
		end
	end
	
	local function OnCommandDebugViewAngles()
		kFlashyViewAngleDebugging = not kFlashyViewAngleDebugging 
	end

	Event.Hook("Console_showviewangles", OnCommandDebugViewAngles)
	
end