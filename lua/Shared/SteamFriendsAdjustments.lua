// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\Shared\SteamFriendsAdjustments.lua
// - Dragon

local oldPlayerUI_GetStatusInfoForUnit = PlayerUI_GetStatusInfoForUnit
function PlayerUI_GetStatusInfoForUnit(player, unit)

    local unitState = oldPlayerUI_GetStatusInfoForUnit(player, unit)
	if unitState then
		unitState.IsSteamFriend = (unit:isa("Player") and not GetAreEnemies(player, unit) and unit:GetIsSteamFriend()) or false
	end
	return unitState
	
end