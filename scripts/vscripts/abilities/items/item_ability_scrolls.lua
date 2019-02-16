-- 获取一个空的技能
local function findEmptyAbility(hero)
	local ability
	for i = 0,23 do
		ability = hero:GetAbilityByIndex(i)
		if ability then
			local name = ability:GetAbilityName()
			if name == "empty_1"
				or name == "empty_2"
			    or name == "empty_3"
			    or name == "empty_4"
			    or name == "empty_5"
			    -- or name == "empty_6"
			   then
				return name
			end
			if hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH and
				name == "empty_6" then
				return name
			end
		end
	end
	return nil
end

function AddAbility(keys)
	local caster = keys.caster
	if not caster:IsRealHero() then return end
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
	local abilityName = string.sub(ability:GetAbilityName(), 6)

	local playerAbility = caster:FindAbilityByName(abilityName)
	if playerAbility then
		if playerAbility:GetLevel() >= caster:GetLevel() then
			msg.bottom("#ability_cant_bigger_than_hero_level", playerID)
		elseif playerAbility:GetLevel() >= playerAbility:GetMaxLevel() then
			msg.bottom("#mh_hud_error_ability_reached_max_level", playerID)
		else
			local charges = ability:GetCurrentCharges() - 1
			if charges <= 0 then
				ability:RemoveSelf()
			else
				ability:SetCurrentCharges(charges)
			end
			playerAbility:UpgradeAbility(true)
		end
	else
		local emptyAbility = findEmptyAbility(caster)
		if not emptyAbility then
			msg.bottom("#mh_hud_error_ability_is_full", playerID)
			return
		end
		local charges = ability:GetCurrentCharges() - 1
		if charges <= 0 then
			ability:RemoveSelf()
		else
			ability:SetCurrentCharges(charges)
		end
		caster:AddAbility(abilityName)
		caster:SwapAbilities(abilityName,emptyAbility,true,false)
		caster:RemoveAbility(emptyAbility)
		caster:FindAbilityByName(abilityName):SetLevel(1)
	end
end