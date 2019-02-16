function OnRandomStar(keys)
	local caster = keys.caster
	if not caster:IsRealHero() then return end
	caster:RandomStar()

	local ability = keys.ability
	local charges = ability:GetCurrentCharges() - 1
    if charges <= 0 then
        UTIL_RemoveImmediate(ability)
    else
        ability:SetCurrentCharges(charges)
    end
end