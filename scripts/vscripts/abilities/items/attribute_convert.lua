function OnConvertStrToAgi(keys)
	local caster = keys.caster
	local amount = keys.ability:GetSpecialValueFor("amount")
	local str = caster:GetBaseStrength()
	local ability = keys.ability
	for i = 0, 12 do
		local item = caster:GetItemInSlot(i)
	end
	if str < amount then
		msg.bottom("#strength_low", caster:GetPlayerID())
		local gold = GetItemCost(ability:GetAbilityName())
		-- caster:ModifyGold(gold,true,DOTA_ModifyGold_Unspecified)
	else
		local charges = ability:GetCurrentCharges()
		if charges > 1 then
			ability:SetCurrentCharges(charges - 1)
		else
			UTIL_RemoveImmediate(ability)
		end
		caster:SetBaseAgility(caster:GetBaseAgility() + amount)
		caster:SetBaseStrength(caster:GetBaseStrength() - amount)
	end
end

function OnConvertStrToInt(keys)
	local caster = keys.caster
	local amount = keys.ability:GetSpecialValueFor("amount")
	local str = caster:GetBaseStrength()
	local ability = keys.ability
	
	if str < amount then
		msg.bottom("#strength_low", caster:GetPlayerID())
		local gold = GetItemCost(ability:GetAbilityName())
		-- caster:ModifyGold(gold,true,DOTA_ModifyGold_Unspecified)
	else
		local charges = ability:GetCurrentCharges()
		if charges > 1 then
			ability:SetCurrentCharges(charges - 1)
		else
			UTIL_RemoveImmediate(ability)
		end
		caster:SetBaseStrength(caster:GetBaseStrength() - amount)
		caster:SetBaseIntellect(caster:GetBaseIntellect() + amount)
	end
end

function OnConvertAgiToStr(keys)
	local caster = keys.caster
	local amount = keys.ability:GetSpecialValueFor("amount")
	local agi = caster:GetBaseAgility()
	local ability = keys.ability
	
	if agi < amount then
		msg.bottom("#agility_low", caster:GetPlayerID())
		local gold = GetItemCost(ability:GetAbilityName())
		-- caster:ModifyGold(gold,true,DOTA_ModifyGold_Unspecified)
	else
		local charges = ability:GetCurrentCharges()
		if charges > 1 then
			ability:SetCurrentCharges(charges - 1)
		else
			UTIL_RemoveImmediate(ability)
		end
		caster:SetBaseStrength(caster:GetBaseStrength() + amount)
		caster:SetBaseAgility(caster:GetBaseAgility() - amount)
	end
end


function OnConvertAgiToInt(keys)
	local caster = keys.caster
	local amount = keys.ability:GetSpecialValueFor("amount")
	local agi = caster:GetBaseAgility()
	local ability = keys.ability
        
	
	if agi < amount then
		msg.bottom("#agility_low", caster:GetPlayerID())
		local gold = GetItemCost(ability:GetAbilityName())
		-- caster:ModifyGold(gold,true,DOTA_ModifyGold_Unspecified)
	else
		local charges = ability:GetCurrentCharges()
		if charges > 1 then
			ability:SetCurrentCharges(charges - 1)
		else
			UTIL_RemoveImmediate(ability)
		end
		caster:SetBaseIntellect(caster:GetBaseIntellect() + amount)
		caster:SetBaseAgility(caster:GetBaseAgility() - amount)
	end
end

function OnConvertIntToStr(keys)
	local caster = keys.caster
	local amount = keys.ability:GetSpecialValueFor("amount")
	local int = caster:GetBaseIntellect()
	local ability = keys.ability
	
	if int < amount then
		msg.bottom("#intellect_low", caster:GetPlayerID())
		local gold = GetItemCost(ability:GetAbilityName())
		-- caster:ModifyGold(gold,true,DOTA_ModifyGold_Unspecified)
	else
		local charges = ability:GetCurrentCharges()
		if charges > 1 then
			ability:SetCurrentCharges(charges - 1)
		else
			UTIL_RemoveImmediate(ability)
		end
		caster:SetBaseStrength(caster:GetBaseStrength() + amount)
		caster:SetBaseIntellect(caster:GetBaseIntellect() - amount)
	end
end

function OnConvertIntToAgi(keys)
	local caster = keys.caster
	local amount = keys.ability:GetSpecialValueFor("amount")
	local int = caster:GetBaseIntellect()
	local ability = keys.ability
	
	if int < amount then
		msg.bottom("#intellect_low", caster:GetPlayerID())
		local gold = GetItemCost(ability:GetAbilityName())
		-- caster:ModifyGold(gold,true,DOTA_ModifyGold_Unspecified)
	else
		local charges = ability:GetCurrentCharges()
		if charges > 1 then
			ability:SetCurrentCharges(charges - 1)
		else
			UTIL_RemoveImmediate(ability)
		end
		caster:SetBaseAgility(caster:GetBaseAgility() + amount)
		caster:SetBaseIntellect(caster:GetBaseIntellect() - amount)
	end
end