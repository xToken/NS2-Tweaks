// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\Shared\MetabolizeAdjustments.lua
// - Dragon

local kMetabolizeDelay = 2.0
local kMetabolizeEnergyRegain = 35
local kMetabolizeHealthRegain = 15

function Fade:MovementModifierChanged(newMovementModifierState, input)

    if newMovementModifierState then
        if self:GetHasMovementSpecial() and not self:GetHasMetabolizeDelay() and self:GetEnergy() >= kMetabolizeEnergyCost then
			self.timeMetabolize = Shared.GetTime()
        end
    end
    
end

function Fade:GetHasMetabolizeDelay()
    return self.timeMetabolize + kMetabolizeDelay > Shared.GetTime()
end

local function ProcessMetabolizeTag(self, tagName)

	if tagName == "metabolize" then
		local player = self:GetParent()
		if player then
			player:DeductAbilityEnergy(kMetabolizeEnergyCost)
			player:TriggerEffects("metabolize")
			if player:GetCanMetabolizeHealth() then
				local totalHealed = player:AddHealth(kMetabolizeHealthRegain, false, false)
				if Client and totalHealed > 0 then
					local GUIRegenerationFeedback = ClientUI.GetScript("GUIRegenerationFeedback")
					GUIRegenerationFeedback:TriggerRegenEffect()
					local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
					cinematic:SetCinematic(kRegenerationViewCinematic)
				end
			end
			player:AddEnergy(kMetabolizeEnergyRegain)
		end
    end

end

local originalSwipeBlinkOnTag
originalSwipeBlinkOnTag = Class_ReplaceMethod("SwipeBlink", "OnTag",
	function(self, tagName)
		originalSwipeBlinkOnTag(self, tagName)
		ProcessMetabolizeTag(self, tagName)
	end
)
	
local originalStabBlinkOnTag
originalStabBlinkOnTag = Class_ReplaceMethod("StabBlink", "OnTag",
	function(self, tagName)
		originalStabBlinkOnTag(self, tagName)
		ProcessMetabolizeTag(self, tagName)
	end
)

function Fade:OnUpdateAnimationInput(modelMixin)

    if not self:GetHasMetabolizeAnimationDelay() then
        Alien.OnUpdateAnimationInput(self, modelMixin)

        if self.timeOfLastPhase + 0.5 > Shared.GetTime() then
            modelMixin:SetAnimationInput("move", "teleport")
        end
    else
		modelMixin:SetAnimationInput("ability", "vortex")
		modelMixin:SetAnimationInput("activity", "primary")
	end

end

local networkVars = { altmode = "private boolean" }

Shared.LinkClassToMap("Fade", Fade.kMapName, networkVars, true)

//Make sure its built, remove mapname ref to avoid weapon creation.
local oldBuildTechData = BuildTechData
function BuildTechData()
	local techData = oldBuildTechData()
	for index, record in ipairs(techData) do 
		if record[kTechDataId] == kTechId.MetabolizeEnergy then
			record[kTechDataMapName] = nil
		end
	end
	return techData
end

function StabBlink:GetHUDSlot()
	local player = self:GetParent()
    if player and player.altmode then
		return 3
	end
    return 2
end

//Fucking hypie
local oldWeaponOwnerMixinSwitchWeapon = WeaponOwnerMixin.SwitchWeapon
function WeaponOwnerMixin:SwitchWeapon(hudSlot)
	if self:isa("Fade") and hudSlot == 2 and self.altmode then
		if self:GetHasMovementSpecial() and not self:GetHasMetabolizeDelay() and self:GetEnergy() >= kMetabolizeEnergyCost then
			self.timeMetabolize = Shared.GetTime()
        end
		return false
	end
	return oldWeaponOwnerMixinSwitchWeapon(self, hudSlot)
end

if Server then

	local originalAlienCopyPlayerDataFrom
	originalAlienCopyPlayerDataFrom = Class_ReplaceMethod("Alien", "CopyPlayerDataFrom",
		function(self, player)
			originalAlienCopyPlayerDataFrom(self, player)
			self.altmode = player.altmode
		end
	)

	function IAmRetarded(client)
		if client then
			local player = client:GetControllingPlayer()
			if player then
				if not player.altmode then
					player.altmode = true
				else
					player.altmode = false
				end
				ServerAdminPrint(client, "Fade alt mode " .. ConditionalValue(player.altmode, "enabled.", "disabled."))
			end
		end
	end

	Event.Hook("Console_hypiemode", IAmRetarded)
	
end