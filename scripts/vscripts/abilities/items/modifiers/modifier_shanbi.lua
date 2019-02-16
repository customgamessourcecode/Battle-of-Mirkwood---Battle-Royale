modifier_shanbi = class({})

function modifier_shanbi:GetTexture()
	return "bom/shanbi"
end

function modifier_shanbi:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EVASION_CONSTANT
	}
end

function modifier_shanbi:IsHidden()
	return true
end

function modifier_shanbi:OnCreated()
	if IsServer() then
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf",PATTACH_ABSORIGIN_FOLLOW,self:GetParent())
		ParticleManager:SetParticleControlEnt(particle,0,self:GetParent(),PATTACH_ABSORIGIN_FOLLOW,"follow_origin",self:GetParent():GetOrigin(),false)
		self:AddParticle(particle,true,false,0,true,false)
	end
end

function modifier_shanbi:GetModifierEvasion_Constant()
	return self:GetAbility():GetSpecialValueFor("evasion_bonus")
end