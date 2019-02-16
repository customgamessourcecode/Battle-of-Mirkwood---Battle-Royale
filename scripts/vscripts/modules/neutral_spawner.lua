-- 这个刷怪系统作为开始的辅助方法，帮助玩家度过初始阶段
local TOTAL_CREATURES_SPAWN = 200
local MAP_MAX_BASIC_CREATURES = 150
local MAP_BASIC_CREATURES_SPAWN_COUNT = 10

local ALL_CREATURES = {
	"npc_dota_creature_basic_zombie_exploding",
	"npc_dota_creature_zombie",
	"npc_dota_creature_zombie_crawler",
	"npc_dota_creature_bear",
	"npc_dota_creature_bear_large",
	"npc_dota_creature_tormented_soul",
	"npc_dota_creature_spider",
	"npc_dota_creature_red_bear",
}

local DEATH_SOUND = {
	npc_dota_creature_zombie = "Zombie.Death",
	npc_dota_creature_bear = "Bear.Death",
	npc_dota_creature_bear_large = "BearLarge.Death",
}

if NeutralSpawner == nil then NeutralSpawner = class({}) end

function NeutralSpawner:constructor()

	if IsInToolsMode() then return end

	for k, v in pairs(ALL_CREATURES) do
		PrecacheUnitByNameAsync(v, function() end)
	end

	self.nCreatureSpawned = 0
	self.vCreatures = {}

	ListenToGameEvent("entity_killed", Dynamic_Wrap(NeutralSpawner, "OnEntityKilled"), self)
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(NeutralSpawner, "OnGameRulesStateChange"), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(NeutralSpawner, "OnNpcSpawned"), self)
end

function NeutralSpawner:OnNpcSpawned(keys)
	local unit = EntIndexToHScript(keys.entindex)
	if unit and unit.GetUnitName and table.contains(ALL_CREATURES, unit:GetUnitName()) then
		unit:SetForwardVector(RandomVector(1))
	end	
end

function NeutralSpawner:OnGameRulesStateChange()
	local newState = GameRules:State_Get()

	-- if IsInToolsMode() then return end

	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:SetupCreatureSpawners()
		self:Begin()
	end
end

function NeutralSpawner:Begin()
	for i = 1, MAP_MAX_BASIC_CREATURES /MAP_BASIC_CREATURES_SPAWN_COUNT do
		Timer(i, function()
			for j = 1, MAP_BASIC_CREATURES_SPAWN_COUNT do
				self:SpawnACreature()
			end	
		end)
	end
end
function NeutralSpawner:SpawnACreature()
	local unit = table.random(ALL_CREATURES)
	local randomPos = GameRules.GameMode:GetRandomValidPosition()

	self.nCreatureSpawned = self.nCreatureSpawned + 1
	if self.nCreatureSpawned >= TOTAL_CREATURES_SPAWN 
		and not self.bBonusNeutralSpawnerCreated
		then
		self.bBonusNeutralSpawnerCreated = true
	end

	-- local unit = CreateUnitByNameAsync(unit, randomPos, true, nil, ni, DOTA_TEAM_NEUTRALS, function(_unit)
	-- 	FindClearSpaceForUnit(_unit, randomPos, true)
	-- 	self.vCreatures[_unit] = true
	-- end)

	local unit = CreateUnitByName(unit, randomPos, true, nil, ni, DOTA_TEAM_NEUTRALS)
	Timer(function()
		FindClearSpaceForUnit(unit, randomPos, true)
		self.vCreatures[unit] = true
	end)
	
end

function NeutralSpawner:OnEntityKilled(keys)
	local hDeadUnit = EntIndexToHScript( keys.entindex_killed )
	local hAttacker = EntIndexToHScript( keys.entindex_attacker )

	if hDeadUnit:IsCreature() then
		local sound = DEATH_SOUND[hDeadUnit:GetUnitName()]
		if sound then
			EmitSoundOn(sound, hDeadUnit)
		else
			EmitSoundOn("Zombie.Death", hDeadUnit)
		end

		-- 根据实际情况决定刷怪不刷怪
		for creature, _ in pairs(self.vCreatures) do
			if IsValidAlive(creature) then
			else
				self.vCreatures[creature] = nil
			end
		end

		if GameRules.nCountDownTimer < GameRules.FightingArea.vTimeMarks[1] and table.count(self.vCreatures) > 80 then
			--pass
		elseif GameRules.nCountDownTimer < GameRules.FightingArea.vTimeMarks[2] and table.count(self.vCreatures) > 30 then
			--pass
		-- 在最后一次缩圈的时候不再刷小怪！
		elseif GameRules.nCountDownTimer < GameRules.FightingArea.vTimeMarks[3] and table.count(self.vCreatures) > 10 then
			-- pass
		else
			self:SpawnACreature()
		end

		local bloodEffect = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( bloodEffect, PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, hDeadUnit, PATTACH_POINT_FOLLOW, "attach_hitloc", hDeadUnit:GetAbsOrigin(), true )
		ParticleManager:SetParticleControl( nFXIndex, 1, hDeadUnit:GetAbsOrigin() )
		local flHPRatio = math.min( 1.0, hDeadUnit:GetMaxHealth() / 200 )
		ParticleManager:SetParticleControlForward( nFXIndex, 1, RandomFloat( 0.5, 1.0 ) * flHPRatio * ( hAttacker:GetAbsOrigin() - hDeadUnit:GetAbsOrigin() ):Normalized() )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end

function NeutralSpawner:CreateNeutralSpawnerAtPos(pos)
	local volume_name = DoUniqueString("volume")
    local volume_perfab = Entities:FindByName(nil,"neutral_volume")
    local volume = SpawnEntityFromTableSynchronous("trigger_dota",{
        targetname = volume_name,
        origin = pos,
        model = volume_perfab:GetModelName(),
        every_unit = true,
    })

    local spawner = SpawnEntityFromTableSynchronous("npc_dota_neutral_spawner", {
        targetname = "spawner_" .. volume_name,
        origin = pos,
        NeutralType = RandomInt(0,3),
        PullType = RandomInt(0,2),
        VolumeName = volume_name
    })

    return {spawner, volume}
end

----------------------------------------------------------------------------------------------------
-- 在固定的位置生成刷怪器
----------------------------------------------------------------------------------------------------
function NeutralSpawner:SetupCreatureSpawners()
    local ents = Entities:FindAllByClassname("info_target") -- 在所有的creature_camp_mark位置生成一个野怪刷怪点
    for _, pos_ent in pairs(ents) do
        if string.find(pos_ent:GetName(), "creature_camp_mark") then
            self:CreateNeutralSpawnerAtPos(pos_ent:GetAbsOrigin())
        end
    end
end

function NeutralSpawner:OnFightingAreaRescale(center, radius)
	local neutralSpawners = Entities:FindAllByClassname("npc_dota_neutral_spawner")
	for _, spawner in pairs(neutralSpawners) do
		if ((spawner:GetOrigin() - center):Length2D() > radius) then
			UTIL_Remove(spawner)
		end
	end
end
