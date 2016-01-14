// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\Shared\ArmoryAdjustments.lua
// - Dragon

//Setting a global when the armory upgrades... impacts all armories...
local kArmoryHealthbarHeight = gArmoryHealthHeight
local kAdvancedArmoryHealthbarHeight = 1.7

function Armory:GetHealthbarOffset()
	if self:GetTechId() == kTechId.AdvancedArmory then
		return kAdvancedArmoryHealthbarHeight
	end
    return kArmoryHealthbarHeight
end