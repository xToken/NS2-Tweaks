// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\Shared\MucousAdjustments.lua
// - Dragon

if Server then

	local oldMucousableMixinComputeDamageOverrideMixin = MucousableMixin.ComputeDamageOverrideMixin
	function MucousableMixin:ComputeDamageOverrideMixin(attacker, damage, damageType, hitPoint)
		local ogdamage = damage
		damage = oldMucousableMixinComputeDamageOverrideMixin(self, attacker, damage, damageType, hitPoint)
		if damage == 0 and ogdamage > 0 then
			local weapon = attacker:GetActiveWeapon()
			local techId
			if attacker:isa("Alien") and ( weapon.secondaryAttacking or weapon.shootingSpikes) then
				techId = weapon:GetSecondaryTechId()
			else
				techId = weapon:GetTechId()
			end
			if techId and HitSound_IsEnabledForWeapon( techId ) then
				// Damage message will be sent at the end of OnProcessMove by the HitSound system
				HitSound_RecordHit( attacker, self, ogdamage, self:GetOrigin(), ogdamage, techId )
			end
		end
		return damage
	end

end