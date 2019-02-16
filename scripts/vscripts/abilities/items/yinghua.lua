function yinghuaSetValue(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not ability then return end
	caster.damage_block = ability:GetSpecialValueFor("damage_block")
end