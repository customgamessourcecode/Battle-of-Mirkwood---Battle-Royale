modifier_provides_vision = class({})

function modifier_provides_vision:DeclareFunctions()
	return {MODIFIER_STATE_PROVIDES_VISION}
end

function modifier_provides_vision:GetModifierProvidesFOWVision()
	return 1
end