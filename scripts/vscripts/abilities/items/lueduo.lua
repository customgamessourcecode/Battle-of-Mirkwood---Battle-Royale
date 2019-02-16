function lueduoGrantsGold(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = caster:FindAbilityByName("lueduo")
	if not target:IsRealHero() then
		local level = ability:GetLevel()
		local bounty = target:GetGoldBounty()
		local steal_pct = ability:GetSpecialValueFor("steal_pct")
		local steal_base_value = ability:GetSpecialValueFor('steal_base_value')
		local bonus = steal_base_value + math.floor(bounty * steal_pct / 100)

		caster:ModifyGold(bonus,true,DOTA_ModifyGold_Unspecified)
		utilsPopups.ShowGoldGain(target, bonus)
	end
end