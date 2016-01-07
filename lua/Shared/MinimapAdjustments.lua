// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\CompMod\Shared\MinimapAdjustments.lua
// - Dragon

local oldMapBlipMixinGetMapBlipInfo = MapBlipMixin.GetMapBlipInfo
function MapBlipMixin:GetMapBlipInfo()
	local success, blipType, blipTeam, isAttacked, isParasited = oldMapBlipMixinGetMapBlipInfo(self)
	if self:isa("Embryo") then
		//Fucking seriously NS2??????????????????
		blipType = kMinimapBlipType["Egg"]
	end
	return success, blipType, blipTeam, isAttacked, isParasited
end