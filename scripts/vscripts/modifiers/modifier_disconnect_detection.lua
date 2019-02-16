modifier_disconnect_detection = class({})

function modifier_disconnect_detection:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_disconnect_detection:IsHidden()
	return true
end

function modifier_disconnect_detection:IsPurgable()
	return false
end

function modifier_disconnect_detection:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_disconnect_detection:RemoveOnDeath()
	return false
end

function modifier_disconnect_detection:OnIntervalThink()
	if IsServer() then
		local owner = self:GetParent()
		local state = PlayerResource:GetConnectionState(owner:GetPlayerID())

		if state ~= DOTA_CONNECTION_STATE_CONNECTED and self.flDisconnectStartTime == nil then
			self.flDisconnectStartTime = GameRules:GetGameTime()
			owner.flDisconnectStartTime = self.flDisconnectStartTime
		end

		if state == DOTA_CONNECTION_STATE_CONNECTED then
			self.flDisconnectStartTime = nil
			owner.flDisconnectStartTime = nil

			if self.bDisconnected then
				self.bDisconnected = false
				owner.bDisconnected = false

				Timer(0, function()
					owner:RespawnHero(false, false)
				end)
			end
			
			GameRules.ConnectionManager:OnPlayerHeroConnected(owner)
		end

		-- 非连接状态满20秒，那么进入掉线状态
		if self.flDisconnectStartTime and GameRules:GetGameTime() > self.flDisconnectStartTime + 20 and not self.bDisconnected then
			GameRules.ConnectionManager:OnPlayerDisconnected(owner)
			self.bDisconnected = true
			owner.bDisconnected = true
			owner:SetOrigin(Vector(99999,99999,0))
		end

		if owner.nTeamNumberBeforeDisconnected == nil then
			local team = owner:GetTeamNumber()
			if table.contains({2,3,6,7,8,9,10,11,12,13}, team) then
				owner.nTeamNumberBeforeDisconnected = team
			end
		end
	end
end

function modifier_disconnect_detection:CheckState()
	if self.bDisconnected then
		return {
			[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_DISARMED] = true,
		}
	end
	return {}
end