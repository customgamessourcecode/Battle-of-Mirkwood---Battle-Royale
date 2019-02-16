LinkLuaModifier("modifier_bingshuangzhixin_slow","abilities/items/modifiers/modifier_bingshuangzhixin_slow",LUA_MODIFIER_MOTION_NONE)

-- 当冰霜之心命中了一个敌人，为他和他周围的单位添加减速什么的
function OnBingshuangzhixinHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local radius = ability:GetSpecialValueFor("explode_radius")
	local ratio = ability:GetSpecialValueFor("damage_ratio")

	-- 减速效果和伤害

	ApplyDamage({
		damage = caster:GetIntellect() * ratio / 100,
		attacker = caster,
		victim = target,
		ability = ability,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE
	})

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),target:GetOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
	for _, enemy in pairs(enemies) do
		target:AddNewModifier(caster,ability,"modifier_bingshuangzhixin_slow",{})
	end
end