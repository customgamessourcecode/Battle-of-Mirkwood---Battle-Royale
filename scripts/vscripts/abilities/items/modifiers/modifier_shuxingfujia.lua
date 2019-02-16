modifier_shuxingfujia = class({})

function modifier_shuxingfujia:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

function modifier_shuxingfujia:GetModifierBonusStats_Strength()
		return self:GetAbility():GetSpecialValueFor("attribute_bonus")
end

function modifier_shuxingfujia:GetModifierBonusStats_Agility()
		return self:GetAbility():GetSpecialValueFor("attribute_bonus")
end

function modifier_shuxingfujia:GetModifierBonusStats_Intellect()
		return self:GetAbility():GetSpecialValueFor("attribute_bonus")
end

function modifier_shuxingfujia:GetTexture()
	return 'bom/shuxingfujia'
end