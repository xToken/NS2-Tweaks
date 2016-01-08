// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\CompMod\Shared\MinimapAdjustments.lua
// - Dragon

if Server then

	local oldCombatMixinOnTakeDamage = CombatMixin.OnTakeDamage
    function CombatMixin:OnTakeDamage(damage, attacker, doer, point, direction, damageType, preventAlert)
		oldCombatMixinOnTakeDamage(self, damage, attacker, doer, point, direction, damageType, preventAlert)
        local notifiyTarget = not doer or not doer.GetNotifiyTarget or doer:GetNotifiyTarget(self)
        if attacker and notifiyTarget and (damage > 0 or (attacker:isa("Hallucination") or attacker.isHallucination)) and point then
			//Try moar things here.
			//Special case whip bombs cause NS2
			if doer:isa("WhipBomb") then
				if doer.shooter and doer.shooter:GetOrigin() then
					self.lastTakenDamageOrigin = doer.shooter:GetOrigin()
				else
					self.lastTakenDamageOrigin = self:GetOrigin()
				end
			elseif doer and doer.GetOwner and doer:GetOwner() and doer.UseOwnerForDamageOrigin and doer:UseOwnerForDamageOrigin() then
				self.lastTakenDamageOrigin = doer:GetOwner():GetOrigin()
			elseif doer and doer.GetParent and doer:GetParent() then
				self.lastTakenDamageOrigin = doer:GetParent():GetOrigin()
			elseif doer and doer.GetOrigin then
				self.lastTakenDamageOrigin = doer:GetOrigin()
			else
				//Last hope, use our origin.. just to prevent assert
				self.lastTakenDamageOrigin = self:GetOrigin()
			end
        end    
    end

end

function Spit:UseOwnerForDamageOrigin()
    return true
end

function Shockwave:UseOwnerForDamageOrigin()
    return true
end

function DotMarker:GetNotifiyTarget()
    return true
end

function Flamethrower:GetNotifiyTarget()
    return true
end