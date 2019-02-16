if FightingArea == nil then FightingArea = class({}) end

function FightingArea:constructor()
	self.vBorderParticles = {}
	self.vTimeMarks = {	13*60, 9*60, 5*60, } -- 这个时间是倒数的时间！也就是距离结束10分钟缩第一个圈！
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(FightingArea, "OnGameRulesStateChange"), self)
	self.nRescaleState = 0
end

function FightingArea:GetRescaleState()
	return self.nRescaleState
end

function FightingArea:OnGameRulesStateChange()
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if not self.bTimer then
			self.bTimer = true
			self:CreateTimer()
		end
	end
end

function FightingArea:CreateTimer()
	Timer(1, function()
		local countDown = GameRules.nCountDownTimer
		local timeMarks = self.vTimeMarks
		if countDown == timeMarks[1] + 60 then
			self.rescaleRadius = 5500
			CustomGameEventManager:Send_ServerToAllClients("rescale_alert",{time_remaining = 60})
			self:RescalePredict()
		end
		if countDown == timeMarks[1] + 30 then
			CustomGameEventManager:Send_ServerToAllClients("rescale_alert",{time_remaining = 30})
		end
		if countDown == timeMarks[1] then
			self.nRescaleState = 1
			self:Rescale(1)
		end
		if countDown == timeMarks[2] + 60 then
			self.oldRescaleRadius = self.rescaleRadius
			self.rescaleRadius = 4000
			CustomGameEventManager:Send_ServerToAllClients("rescale_alert",{time_remaining = 60})
			self:RescalePredict()
		end 
		if countDown == timeMarks[2] + 30 then
			CustomGameEventManager:Send_ServerToAllClients("rescale_alert",{time_remaining = 30})
		end
		if countDown == timeMarks[2] then
			self.nRescaleState = 2
			self:Rescale(2)

			-- 在第二次缩圈之后，游戏可以安全离开
			GameRules:SetSafeToLeave(true)

			-- 在第二次缩圈之后，每过半秒发送DPS数据到客户端
			Timer(1, function()
				local dpsData = {}
				if GameRules.vDPSData == nil then return 1 end
				for playerId, dps in pairs(GameRules.vDPSData) do
					table.insert(dpsData, {p = playerId, d = dps})
				end

				table.sort(dpsData, function(a,b) return a.d > b.d end)

				CustomNetTables:SetTableValue("player_data", "dps_data", dpsData)
				return 1
			end)
		end
		if countDown == timeMarks[3] + 60 then
			self.oldRescaleRadius = self.rescaleRadius
			self.rescaleRadius = 2800
			CustomGameEventManager:Send_ServerToAllClients("rescale_alert",{time_remaining = 60})
			self:RescalePredict()
		end
		if countDown == timeMarks[3] + 30 then
			CustomGameEventManager:Send_ServerToAllClients("rescale_alert",{time_remaining = 30})		
		end 
		if countDown == timeMarks[3] then
			self.nRescaleState = 3
			self:Rescale(3)
		end
		if countDown >= timeMarks[1] and countDown <= timeMarks[1] + 10 then
			CustomGameEventManager:Send_ServerToAllClients("rescale_alert",{time_remaining = countDown - timeMarks[1]})		
		end
		if countDown >= timeMarks[2] and countDown <= timeMarks[2] + 10 then
			CustomGameEventManager:Send_ServerToAllClients("rescale_alert",{time_remaining = countDown - timeMarks[2]})
		end
		if countDown >= timeMarks[3] and countDown <= timeMarks[3] + 10 then
			CustomGameEventManager:Send_ServerToAllClients("rescale_alert",{time_remaining = countDown - timeMarks[3]})		
		end
		return 1
	end)
end

function FightingArea:RescalePredict()
	local radius = self.rescaleRadius
	if not self.rescaleCenter then
		local randomRadius = GetWorldMaxX() / 2 - self.rescaleRadius
		self.rescaleCenter = RandomVector(RandomFloat(0, randomRadius))
	else
		local oldCenter = self.rescaleCenter
		local randomRadius = self.oldRescaleRadius - self.rescaleRadius
		self.rescaleCenter = oldCenter + RandomVector(RandomFloat(0, randomRadius))
	end

	CustomGameEventManager:Send_ServerToAllClients("minimap_rescale_predict",{
		x = self.rescaleCenter.x,
		y = self.rescaleCenter.y,
		z = self.rescaleCenter.z,
		radius = self.rescaleRadius,
	})
end

function FightingArea:Rescale(stage)
	local radius = self.rescaleRadius
	local center = self.rescaleCenter
	self.radiusRescaled = radius
	self.centerRescaled = center

	Notifications:TopToAll({text="#fighting_area_rescaled", duration=10, style={color="red", ["font-size"] = "50px"}})
	
	local rescaleData = {
		x = self.rescaleCenter.x,
		y = self.rescaleCenter.y,
		z = self.rescaleCenter.z,
		radius = self.rescaleRadius,
	}
	CustomGameEventManager:Send_ServerToAllClients("minimap_rescale", rescaleData)
	CustomNetTables:SetTableValue('game_state', 'minimap_rescale_data', rescaleData)

	if not self.bEnterFightingAreaChecker then
		self.bEnterFightingAreaChecker = true
		Timer(0, function()
			-- 对毒圈范围内的生物添加modifier
			for i = 0, DOTA_MAX_TEAM_PLAYERS do
				local player = PlayerResource:GetPlayer(i)
				if player then
					hero = player:GetAssignedHero()
					if hero then
						local o = hero:GetOrigin()
						local length = (o - self.centerRescaled):Length2D()
						if (length > self.radiusRescaled ) then
							-- 移动到范围之内，并停止
							if not hero:HasModifier("modifier_fighting_area_poison") then
								hero:AddNewModifier(hero,nil,"modifier_fighting_area_poison",{})
							end
						else
							if hero:HasModifier("modifier_fighting_area_poison") then
								hero:RemoveModifierByName("modifier_fighting_area_poison")
							end
						end
					end
				end
			end

			-- 圈外的生物也会受到伤害
			local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,Vector(0,0,0),nil,9999,DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_ALL,DOTA_UNIT_TARGET_FLAG_NONE,FIND_ANY_ORDER,false)
			for _, unit in pairs(units) do
				local o = unit:GetOrigin()
				local length = (o - self.centerRescaled):Length2D()
				if (length > self.radiusRescaled) then
					if not unit:HasModifier("modifier_fighting_area_poison") then
						unit:AddNewModifier(unit,nil,"modifier_fighting_area_poison",{})
					end
				else
					if unit:HasModifier("modifier_fighting_area_poison") then
						unit:RemoveModifierByName("modifier_fighting_area_poison")
					end
				end
			end

			-- 告知neutral spawner外面的可以不刷了
			GameRules.NeutralSpawner:OnFightingAreaRescale(center, radius)
			return 0.03
		end)
	end

	-- 加入区域缩小的粒子特效
	local borderParticleName = "particles/core/border.vpcf"
	-- 每间隔100的距离放置一个粒子特效
	if self.vBorderParticles then
		for _, pid in pairs(self.vBorderParticles) do
			ParticleManager:DestroyParticle(pid,true)
		end
	end

	self.vBorderParticles = {}

	-- 根据周长计算粒子特效数量
	local c = 3.1415 * 2 * radius
	local particleCount = c / 300

	-- 将两个商人移动到区域内
	local trigger_shop_top_left = Entities:FindByName(nil,"trigger_shop_top_left")
	local shopkeeper_top_left = Entities:FindByName(nil,"shopkeeper_top_left")
	local trigger_shop_bot_right = Entities:FindByName(nil,"trigger_shop_bot_right")
	local shopkeeper_bot_right = Entities:FindByName(nil,"shopkeeper_bot_right")
	local pos1 = GameRules.GameMode:GetRandomValidPosition()
	pos1 = GetGroundPosition(pos1, nil)
	local pos2 = GameRules.GameMode:GetRandomValidPosition()
	pos2 = GetGroundPosition(pos2, nil)
	trigger_shop_top_left:SetOrigin(pos1)
	shopkeeper_top_left:SetOrigin(pos1)
	trigger_shop_bot_right:SetOrigin(pos2)
	if stage == 2 then
		Entities:FindByName(nil, 'trigger_shop_very_big'):SetOrigin(center - Vector(0,0,1024))
	end

	local startingPos = center + Vector(radius, 0, 0)
	local angleInterval = 360 / particleCount
	for i = 0, particleCount do
		local pos = RotatePosition(center,QAngle(0, i * angleInterval, 0), startingPos)
		local groundPos = GetGroundPosition(pos,nil)
		local p = ParticleManager:CreateParticle(borderParticleName,PATTACH_WORLDORIGIN,nil)
		ParticleManager:SetParticleControl(p,0,center)
		ParticleManager:SetParticleControl(p,1,groundPos)
		ParticleManager:SetParticleControl(p,6,groundPos)
		ParticleManager:SetParticleControl(p,10,groundPos)
		table.insert(self.vBorderParticles, p)
	end
end

if GameRules.FightingArea == nil then GameRules.FightingArea = FightingArea() end