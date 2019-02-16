function ShengmingqiequLifeSteal(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = keys.Damage
	local ratio = ability:GetSpecialValueFor("ratio")
	caster:Heal(damage * ratio / 100,ability)
end