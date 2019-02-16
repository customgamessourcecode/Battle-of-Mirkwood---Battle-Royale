modifier_aoshuhongxi = class({})

function modifier_aoshuhongxi:IsHidden()
	return true
end

function modifier_aoshuhongxi:OnCreated(kv)
	if IsServer() then
		self.nChance = self:GetAbility():GetSpecialValueFor('chance')
	end
end

function modifier_aoshuhongxi:OnRefresh(kv)
	if IsServer() then
		self.nChance = self:GetAbility():GetSpecialValueFor('chance')
	end
end

function modifier_aoshuhongxi:OnDealMagicalDamage(kv)
	if IsServer() then
		if RollPercentage(self.nChance) then
			local damage = kv.damage
			local heal = damage * self:GetCaster():GetIntellect() / 100
			self:GetCaster():Heal(heal, self:GetAbility())
		end
	end
end