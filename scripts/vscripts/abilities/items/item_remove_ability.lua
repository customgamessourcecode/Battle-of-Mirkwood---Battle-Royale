function OnPlayerRemoveAbility(keys)
	local caster = keys.caster
	if not caster:IsRealHero() then return end
    UTIL_RemoveImmediate(keys.ability)
	caster.__remove_ability_state = true
	local player = PlayerResource:GetPlayer(caster:GetPlayerID())
	CustomGameEventManager:Send_ServerToPlayer(player, "player_remove_ability", {})
	Notifications:Bottom(PlayerResource:GetPlayer(caster:GetPlayerID()),{text="remove_tooltip", duration=5, style={color="white", ["font-size"]="40px", border="0px"}})
end