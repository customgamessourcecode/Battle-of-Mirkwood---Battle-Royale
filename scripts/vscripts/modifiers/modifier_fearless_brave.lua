local m = class({})

function m:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function m:OnIntervalThink()
	if IsServer() then
		local stack = self:GetStackCount()
		self:GetParent():ModifyGold(stack, true, DOTA_ModifyGold_Unspecified)
	end
end

function m:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end

function m:GetModifierIncomingDamage_Percentage()
	if IsServer() then
		return -5 * self:GetStackCount()
	end
end

function m:GetModifierDamageOutgoing_Percentage()
	if IsServer() then
		return 3 * self:GetStackCount()
	end
end

function m:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function m:GetTexture()
	return 'general/fearless_brave'
end

function m:IsPurgable()
	return false
end

function m:IsHidden()
	return false
end

function m:RemoveOnDeath()
	return false
end

modifier_fearless_brave = m