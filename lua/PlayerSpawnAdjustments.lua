// Natural Selection 2
// lua\PlayerSpawnAdjustments.lua
// - Dragon

Script.Load("lua/Class.lua")

//This shouldnt really be done this way, but its an effective test.  With a network message it may not arrive at the same time as the rest of the respawn, causing some unnatural feeling for the client.
//Probably should be a networked field in the player entity.
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
			
			if origin ~= nil and angles ~= nil then
				success = Team.RespawnPlayer(self, player, origin, angles)
			elseif initialTechPoint ~= nil then
			
				// Compute random spawn location
				local capsuleHeight, capsuleRadius = player:GetTraceCapsule()
				local spawnOrigin = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, initialTechPoint:GetOrigin(), 2, 15, EntityFilterAll())
				
				if not spawnOrigin then
					spawnOrigin = initialTechPoint:GetOrigin() + Vector(2, 0.2, 2)
				end
				
				// Orient player towards tech point
				// 5 Meters above TP is alot, lets try 2.
				local lookAtPoint = initialTechPoint:GetOrigin() + Vector(0, 1, 0)
				local toTechPoint = GetNormalizedVector(lookAtPoint - spawnOrigin)
				success = Team.RespawnPlayer(self, player, spawnOrigin, Angles(GetPitchFromVector(toTechPoint), GetYawFromVector(toTechPoint), 0))
				
			else
				Print("PlayingTeam:RespawnPlayer(): No initial tech point.")
			end
			
			return success
			
		end
	)
	
	local function SpawnPlayer(self)

		if self.queuedPlayerId ~= Entity.invalidId then
		
			local queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
			local team = queuedPlayer:GetTeam()
			
			// Spawn player on top of IP
			local spawnOrigin = self:GetAttachPointOrigin("spawn_point")
			
			//Marine specs have no model, so no angles.  Need view angles here i guess.
			local success, player = team:ReplaceRespawnPlayer(queuedPlayer, spawnOrigin, queuedPlayer:GetViewAngles())
			if success then
			
				player:SetCameraDistance(0)
				
				if HasMixin( player, "Controller" ) and HasMixin( player, "AFKMixin" ) then
					
					if player:GetAFKTime() > self:GetSpawnTime() - 1 then
						
						player:DisableGroundMove(0.1)
						player:SetVelocity( Vector( GetSign( math.random() - 0.5) * 2.25, 3, GetSign( math.random() - 0.5 ) * 2.25 ) )
						
					end
					
				end
				
				self.queuedPlayerId = Entity.invalidId
				self.queuedPlayerStartTime = nil
				
				player:ProcessRallyOrder(self)

				self:TriggerEffects("infantry_portal_spawn")            
				
				return true
				
			else
				Print("Warning: Infantry Portal failed to spawn the player")
			end
			
		end
		
		return false

	end
	
	local function StopSpinning(self)

		self:TriggerEffects("infantry_portal_stop_spin")
		self.timeSpinUpStarted = nil
		
	end
	
	local originalInfantryPortalFinishSpawn
	originalInfantryPortalFinishSpawn = Class_ReplaceMethod("InfantryPortal", "FinishSpawn",
		function(self)
			SpawnPlayer(self)
			StopSpinning(self)
			self.timeSpinUpStarted = nil		
		end
	)

end

if Client then

	//Pitch is stored client side as +/- 1/2 pi in the 'move'.  'ViewAngles' from model are networked as 0-2pi (ish?)
	function CorrectViewPitch(pitch)

		if pitch > math.pi then
			pitch = pitch - (2 * math.pi)
		end
		return pitch

	end

	function OnCommandOverrideSpawnAngles(msg)
		if msg then
			msg.viewPitch = CorrectViewPitch(msg.viewPitch)
			Client.SetYaw(msg.viewYaw)
            Client.SetPitch(msg.viewPitch)
			//Print(string.format("Spawning player with yaw/pitch %s/%s.", ToString(msg.viewYaw), ToString(msg.viewPitch)))
		end
	end
	
	Client.HookNetworkMessage("OverrideSpawnAngles", OnCommandOverrideSpawnAngles)
	
	local kFlashyViewAngleDebugging = true
	local oldCameraHolderMixinSetViewAngles = CameraHolderMixin.SetViewAngles
	function CameraHolderMixin:SetViewAngles(viewAngles)
		oldCameraHolderMixinSetViewAngles(self, viewAngles)
		if kFlashyViewAngleDebugging then
			if self.printViewAngles == nil or self.printViewAngles < Shared.GetTime() then
				Print(string.format("Player has yaw/pitch %s/%s.", ToString(self.viewYaw), ToString(self.viewPitch)))
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