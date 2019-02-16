function fensuiDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not ability then return end
	local damage = ability:GetSpecialValueFor("damage")

	ApplyDamage({
		attacker = caster,
		victim = target,
		ability = ability,
		damage = damage,
		damage_type = ability:GetAbilityDamageType()
	})
end

function fensuiBonusDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage_percentage = ability:GetSpecialValueFor('damage_hp_ratio')

	local maxHealth = target:GetMaxHealth()
	local damage = maxHealth * damage_percentage / 100

	ApplyDamage({
		attacker = caster,
		victim = target,
		ability = ability,
		damage = damage,
		damage_type = ability:GetAbilityDamageType()
	})
end