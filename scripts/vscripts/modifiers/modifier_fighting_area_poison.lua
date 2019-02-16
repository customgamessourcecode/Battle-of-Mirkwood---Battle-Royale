modifier_fighting_area_poison = class({})

function modifier_fighting_area_poison:IsDebuff()
	return true
end

function modifier_fighting_area_poison:GetTexture()
	return "general/poison"
end

function modifier_fighting_area_poison:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(1)

		local owner = self:GetParent()
		local pid = ParticleManager:CreateParticle("particles/econ/items/viper/viper_ti7_immortal/viper_poison_crimson_debuff_ti7.vpcf",PATTACH_ABSORIGIN_FOLLOW,owner)
		ParticleManager:SetParticleControlEnt(pid,0,owner,PATTACH_ABSORIGIN_FOLLOW,"follow_origin",owner:GetOrigin(),false)
		self:AddParticle(pid,true,false,0,true,false)

		local pid1 = ParticleManager:CreateParticleForPlayer("particles/generic_gameplay/screen_poison_indicator.vpcf", PATTACH_EYES_FOLLOW, self:GetParent(), self:GetParent():GetPlayerOwner())
        ParticleManager:SetParticleControl(pid1, 1, self:GetParent():GetOrigin())
        self:AddParticle(pid1,false,false,0,false,false)
	end
end

function modifier_fighting_area_poison:OnIntervalThink()
	if IsServer() then
		if GameRules.hPoisonDamageDealer == nil then
			GameRules.hPoisonDamageDealer = CreateUnitByName("npc_poison_dummy",Vector(0,0,0),false,nil,nil,DOTA_TEAM_NEUTRALS)
			GameRules.hPoisonDamageDealer:SetOrigin(Vector(0,0,0))
		end

		local damageDealer = GameRules.hPoisonDamageDealer
		if self:GetParent().__hLastDamageHero then
			damageDealer = self:GetParent().__hLastDamageHero
		end

		utilsDamage.DealDamagePercentage(damageDealer, self:GetParent(), 5, nil, DAMAGE_TYPE_PURE)
	end
end

function modifier_fighting_area_poison:OnDestroy()
	if IsServer() then
		if self.damageParticle then
			ParticleManager:DestroyParticle(self.damageParticle, false) 
			self.bShowingDamageIndicator = false
		end
	end
end

function modifier_fighting_area_poison:GetStatusEffectName()
	return "particles/status_fx/status_effect_poison_viper.vpcf"
end

function modifier_fighting_area_poison:DeclareFunctions()
	return {MODIFIER_PROPERTY_DISABLE_HEALING}
end

function modifier_fighting_area_poison:GetDisableHealing()
	return 1
end

function modifier_fighting_area_poison:IsPurgable()
	return false
end