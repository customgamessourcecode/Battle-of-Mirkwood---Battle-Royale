local m = class({})

function m:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function m:GetTexture()
	return 'general/deserter'
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


modifier_shame_of_deserter = m