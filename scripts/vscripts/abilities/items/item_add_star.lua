function OnAddStar(keys)
	local hero = keys.caster
	if not hero:IsRealHero() then return end
	if hero:HasReachedMaxStar() then
		msg.bottom("#player_max_star", hero:GetPlayerID())
	else
		hero:AddStar()
	end
	local ability = keys.ability
	local charges = ability:GetCurrentCharges() - 1
    if charges <= 0 then
        UTIL_RemoveImmediate(ability)
    else
        ability:SetCurrentCharges(charges)
    end
end