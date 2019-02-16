modifier_wuxianhuoli_lua = class({})

function modifier_wuxianhuoli_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
	}
end

function modifier_wuxianhuoli_lua:GetModifierPercentageCooldown()
	return self:GetAbility():GetSpecialValueFor("cooldown_reduce")
end

function modifier_wuxianhuoli_lua:IsPurgable()
	return false
end

function modifier_wuxianhuoli_lua:IsHidden()
	return true
end

function modifier_wuxianhuoli_lua:OnCreated(kv)
end
