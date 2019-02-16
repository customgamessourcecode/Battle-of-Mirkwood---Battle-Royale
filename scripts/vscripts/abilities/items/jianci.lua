function jianciReflect(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not ability then return end

	local level = ability:GetLevel()
	local damage = keys.Damage
	local reflect_ratio = ability:GetSpecialValueFor("reflect_ratio")
	local damage = damage * (reflect_ratio) / 100

	local victim = keys.attacker
	
	ApplyDamage({
		attacker = target,
		victim = victim,
		ability = ability,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
	})
end