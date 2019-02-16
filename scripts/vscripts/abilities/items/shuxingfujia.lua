LinkLuaModifier("modifier_shuxingfujia","abilities/items/modifiers/modifier_shuxingfujia.lua",LUA_MODIFIER_MOTION_NONE)

shuxingfujia = class({})

function shuxingfujia:GetIntrinsicModifierName()
	return "modifier_shuxingfujia"
end

function shuxingfujia:OnUpgrade()
	local hero = self:GetCaster()
	local ability = self
	local ability_name = self:GetAbilityName()

	if ability:GetLevel() <= 1 then
		return
	end

	if not hero:IsRealHero() then return end

	local hero_level = hero:GetLevel()
	local ability_level = ability:GetLevel()
	
	if ability_level > hero_level then
		msg.bottom("#ability_cant_bigger_than_hero_level", hero:GetPlayerID())
		hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
		ability:SetLevel(ability:GetLevel() - 1)
	end
end