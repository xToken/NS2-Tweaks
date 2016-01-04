// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\Shared\SteamFriendsAdjustments.lua
// - Dragon

if Client then

	local oldPlayerUI_GetStatusInfoForUnit = PlayerUI_GetStatusInfoForUnit
	function PlayerUI_GetStatusInfoForUnit(player, unit)

		local unitState = oldPlayerUI_GetStatusInfoForUnit(player, unit)
		if unitState then
			unitState.IsSteamFriend = (unit:isa("Player") and not GetAreEnemies(player, unit) and unit:GetIsSteamFriend()) or false
		end
		return unitState
		
	end

	local oldPlayerMapBlipGetMapBlipTeam
	oldPlayerMapBlipGetMapBlipTeam = Class_ReplaceMethod("PlayerMapBlip", "GetMapBlipTeam",
		function(self, minimap)
		
			local playerTeam = minimap.playerTeam
			local blipTeam = kMinimapBlipTeam.Neutral
			local isSteamFriend = false
			local blipTeamNumber = self:GetTeamNumber()
			
			if blipTeamNumber == kMarineTeamType then
				blipTeam = kMinimapBlipTeam.Marine
			elseif blipTeamNumber== kAlienTeamType then
				blipTeam = kMinimapBlipTeam.Alien
			end		
			
			if self.clientIndex and self.clientIndex > 0 and MinimapMappableMixin.OnSameMinimapBlipTeam(playerTeam, blipTeam) then

				local steamId = GetSteamIdForClientIndex(self.clientIndex)
				if steamId then
					isSteamFriend = Client.GetIsSteamFriend(steamId)
				end

			end
			
			if not self:GetIsActive() then

				if blipTeamNumber == kMarineTeamType then
					blipTeam = kMinimapBlipTeam.InactiveMarine
				elseif blipTeamNumber== kAlienTeamType then
					blipTeam = kMinimapBlipTeam.InactiveAlien
				end

			elseif isSteamFriend then
			
				if blipTeamNumber == kMarineTeamType then
					blipTeam = kMinimapBlipTeam.FriendMarine
				elseif blipTeamNumber== kAlienTeamType then
					blipTeam = kMinimapBlipTeam.FriendAlien
				end
				
			end  

			return blipTeam
		
		end
	)
	
end