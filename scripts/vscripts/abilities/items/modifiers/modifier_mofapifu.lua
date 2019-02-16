local m = class({})

function m:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
	}
end

function m:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor('magical_resistance')
end

function m:GetModifierStatusResistance()
	return self:GetAbility():GetSpecialValueFor('status_resistance')
end

function m:IsPurgable()
	return false
end

function m:IsHidden()
	return true
end

function m:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

modifier_mofapifu = m