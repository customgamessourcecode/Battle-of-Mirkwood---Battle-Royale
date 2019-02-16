modifier_daytime_vision_range_bonus = class({})

function modifier_daytime_vision_range_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_BONUS_DAY_VISION}
end

function modifier_daytime_vision_range_bonus:GetBonusDayVision()
	return 200
end

function modifier_daytime_vision_range_bonus:IsHidden()
	return true
end

function modifier_daytime_vision_range_bonus:IsPurgable()
	return false
end

function modifier_daytime_vision_range_bonus:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end