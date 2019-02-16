-- 游戏中所有可以掉落的技能卷轴
GameRules.RandomDropAbilityScrolls = {
        "item_zhongji",
        "item_fensui",
        "item_shanbi",
        "item_shengmingqiequ",
        "item_yinghua",
        "item_jianci",
        "item_lueduo",
        "item_shuxingfujia",
        "item_gongjishengji",
        "item_fushiguanghuan",
        "item_naijiu",
        "item_hujiazengqiang",
        "item_siwangguanghuan",
        "item_fushu",
        "item_bingshuangzhixin",
        "item_neizaiqianneng",
        "item_wuxianhuoli",
        "item_shixiaolichang",
        "item_mofapifu"
    }
---------------------------------------------------------------------------------
-- 游戏初始化
---------------------------------------------------------------------------------
function GameMode:InitGameMode()
    GameRules.self = self
	-- 设置队伍数量
	local mapName = GetMapName()
	local teams = {2,3,6,7,8,9,10,11,12,13}
	local teamCount = 10
	local playerCountPerTeam = 1
	if mapName == "arena_3x4" then
		teamCount = 4
		playerCountPerTeam = 3
	elseif mapName == "arena_2x6" then
		playerCountPerTeam = 2
		teamCount = 6
    elseif mapName == "arena_4x3" then
        playerCountPerTeam = 4
        teamCount = 3
    elseif mapName == "arena_5v5" then
        playerCountPerTeam = 5
        teamCount = 2
	end

    GameRules.vTeamsInGame = {}

	for i = 1, teamCount do
		GameRules:SetCustomGameTeamMaxPlayers(teams[i],playerCountPerTeam)
        table.insert(GameRules.vTeamsInGame, teams[i])
	end

    Timer(1, function()
        for i = 1, teamCount do
            self:PutStartPositionToRandomPosForTeam(teams[i])
        end
    end)

    self.m_TeamColors = {}
    self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 61, 210, 150 }    --      Teal
    self.m_TeamColors[DOTA_TEAM_BADGUYS]  = { 243, 201, 9 }     --      Yellow
    self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 197, 77, 168 }    --      Pink
    self.m_TeamColors[DOTA_TEAM_CUSTOM_2] = { 255, 108, 0 }     --      Orange
    self.m_TeamColors[DOTA_TEAM_CUSTOM_3] = { 52, 85, 255 }     --      Blue
    self.m_TeamColors[DOTA_TEAM_CUSTOM_4] = { 101, 212, 19 }    --      Green
    self.m_TeamColors[DOTA_TEAM_CUSTOM_5] = { 129, 83, 54 }     --      Brown
    self.m_TeamColors[DOTA_TEAM_CUSTOM_6] = { 27, 192, 216 }    --      Cyan
    self.m_TeamColors[DOTA_TEAM_CUSTOM_7] = { 199, 228, 13 }    --      Olive
    self.m_TeamColors[DOTA_TEAM_CUSTOM_8] = { 140, 42, 244 }    --      Purple

    if mapName ~= "arena_5v5" then
        for team = 0, (DOTA_TEAM_COUNT-1) do
            color = self.m_TeamColors[ team ]
            if color then
                SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
            end
        end
    end
    
    self.nTeamCount = teamCount
    self.isGameTied = false

    local gamemode = GameRules:GetGameModeEntity()
    self.gamemode = gamemode
    GameRules.gamemode = gamemode

    GameRules.nStartingGold = 1200

    GameRules:SetSameHeroSelectionEnabled(true)
    GameRules:SetUseUniversalShopMode(true)
    GameRules:SetHeroSelectionTime(0.1)
    GameRules:SetStrategyTime(3)
    GameRules:SetShowcaseTime(1)
    GameRules:SetPreGameTime(60)
    GameRules:SetPostGameTime(180)
    GameRules:SetTreeRegrowTime(5)
    GameRules:SetGoldTickTime(0.4)
    GameRules:SetGoldPerTick(2)
    GameRules:SetStartingGold(GameRules.nStartingGold)
    gamemode:SetRemoveIllusionsOnDeath(true)
    gamemode:SetFogOfWarDisabled(false)
    gamemode:SetCameraDistanceOverride(1500)
    gamemode:SetSelectionGoldPenaltyEnabled(false)
    gamemode:SetLoseGoldOnDeath(false)
    gamemode:SetBuybackEnabled(false)
    gamemode:SetDamageFilter(Dynamic_Wrap(GameMode, "DamageFilter"), self)
    gamemode:SetExecuteOrderFilter(Dynamic_Wrap(GameMode, "OrderFilter"), self)
    gamemode:SetModifierGainedFilter(Dynamic_Wrap(GameMode, 'ModifierFilter'), self)
    gamemode:SetModifyGoldFilter(Dynamic_Wrap(GameMode, "ModifyGoldFilter"), self)
    gamemode:SetModifyExperienceFilter(Dynamic_Wrap(GameMode, "ModifyExpFilter"), self)

    SendToServerConsole("dota_max_physical_items_purchase_limit 9999")

    local txp = {}
    for i = 0, 50 do
        txp[i] = i * i * 50

    end
    gamemode:SetCustomXPRequiredToReachNextLevel(txp)

    self:SetupGameEventListener()

    -- PUI方面的事件监听
    self:RegisterUIEventListeners()

    if IsInToolsMode() then
        self:EnterDebugMode()
    end

    -- Init modules
    GameRules.StarSystem = Star()
    GameRules.NeutralSpawner = NeutralSpawner()

    GameRules.vDPSData = {}
end

---------------------------------------------------------------------------------
-- 将玩家的出生点放到随机的位置去
---------------------------------------------------------------------------------
function GameMode:PutStartPositionToRandomPosForTeam(team, deadPos)
    -- 将对应队伍的出生点放到随机的位置去
    local playerStarts = Entities:FindAllByClassname("info_player_start_dota")
    for _, start in pairs(playerStarts) do
        if start:GetTeamNumber() == team then
            local randomPos
            if GameRules.FightingArea.radiusRescaled and GameRules.FightingArea.centerRescaled then
                local maxTry = 30
                randomPos = GameRules.FightingArea.centerRescaled + 
                    RandomVector(RandomFloat(
                        GameRules.FightingArea.radiusRescaled * 3.5 / 5, 
                        GameRules.FightingArea.radiusRescaled * 4.5 / 5
                    ))
                while not GridNav:CanFindPath(Entities:FindByName(nil, "world_center"):GetOrigin(),randomPos) do
                    randomPos = GameRules.FightingArea.centerRescaled + 
                        RandomVector(RandomFloat(
                            GameRules.FightingArea.radiusRescaled * 3.5 / 5, 
                            GameRules.FightingArea.radiusRescaled * 4.5 / 5
                        ))
                    maxTry = maxTry - 1
                    if maxTry <= 0 then
                        randomPos =self:GetRandomValidPosition()
                        break
                    end
                end
            else
                local maxTry = 10
                randomPos = self:GetRandomValidPosition()
                if deadPos == nil then deadPos = Vector(0,0,0) end
                while (randomPos - deadPos):Length2D() < 4000 do
                    randomPos =self:GetRandomValidPosition()
                    maxTry = maxTry - 1
                    if maxTry <= 0 then
                        randomPos =self:GetRandomValidPosition()
                        break
                    end
                end
            end

            start:SetOrigin(randomPos)
        end
    end
end

---------------------------------------------------------------------------------
-- 伤害过滤器
---------------------------------------------------------------------------------
function GameMode:DamageFilter(damageTable)
    if not damageTable.entindex_attacker_const and damageTable.entindex_victim_const then return true end

    local attacker = EntIndexToHScript(damageTable.entindex_attacker_const)
    local victim = EntIndexToHScript(damageTable.entindex_victim_const)

    -- 处理硬化技能
    if victim:HasAbility('yinghua') then
        if victim:HasModifier('modifier_skeleton_king_reincarnation_scepter_active') or 
            victim:HasModifier('modifier_skeleton_king_reincarnation_scepter') then
            return true
        else
            local ability = victim:FindAbilityByName('yinghua')
            local damage_block = ability:GetSpecialValueFor('damage_block')
            local damage_min = ability:GetSpecialValueFor('damage_min')
            if damageTable.damage > damage_min then
                damageTable.damage = math.max(damageTable.damage - damage_block, damage_min )
            end
        end
    end

    -- 处理奥术虹吸
    if damageTable.damagetype_const == 2 then
        if attacker:HasModifier('modifier_aoshuhongxi') then
            local modifier = attacker:FindModifierByName('modifier_aoshuhongxi')
            modifier:OnDealMagicalDamage(damageTable)
        end
    end

    if attacker:IsRealHero() and victim:IsRealHero() and damageTable.damage > 0 then
        victim.__hLastDamageHero = attacker

        -- DPS统计
        if GameRules.FightingArea and (GameRules.FightingArea:GetRescaleState() == 2 or GameRules.FightingArea:GetRescaleState() == 3) then
            GameRules.vDPSData = GameRules.vDPSData or {}
            GameRules.vDPSData[attacker:GetPlayerID()] = GameRules.vDPSData[attacker:GetPlayerID()] or 0
            GameRules.vDPSData[attacker:GetPlayerID()] = GameRules.vDPSData[attacker:GetPlayerID()] + damageTable.damage
        end
    end

    if attacker and victim and damageTable.damagetype_const == DAMAGE_TYPE_PHYSICAL then
        local armor = victim:GetPhysicalArmorValue()
        if armor > 0 then
            local new = (0.052 * armor) / (0.9 + 0.048 * armor)
            local old = (0.05  * armor) / (1   + 0.05  * armor)
            new = 1 - new
            old = 1 - old
            local friction = old / new
            if friction < 0.5 then friction = 0.5 end
            if friction > 3.0 then friction = 3.0 end
            damageTable.damage = damageTable.damage * friction
        end
    end

    return true
end

---------------------------------------------------------------------------------
-- buff过滤器
---------------------------------------------------------------------------------
function GameMode:ModifierFilter(filterTable)
    if filterTable.name_const == "modifier_bashed" and filterTable.entindex_ability_const then
        local ability = EntIndexToHScript(filterTable.entindex_ability_const)
        local abilityName = ability:GetAbilityName()
        local caster = EntIndexToHScript(filterTable.entindex_caster_const)
        if (caster:HasAbility('slardar_bash')
            or caster:HasAbility('spirit_breaker_greater_bash')
            or caster:HasAbility('faceless_void_time_lock'))
            and (abilityName == 'item_basher' or abilityName == 'item_abyssal_blade')
            and filterTable.duration < 1.8 -- 2秒的主动还是可以给的
            then
            filterTable.duration = 0
            return false
        end
    end
    return true
end

---------------------------------------------------------------------------------
-- 经验值过滤器
---------------------------------------------------------------------------------
function GameMode:ModifyExpFilter(filterTable)
    local playerid = filterTable.player_id_const
    local exp = filterTable.experience
    local reason = filterTable.reason_const
    local player = PlayerResource:GetPlayer(playerid)
    local hero = player:GetAssignedHero()

    -- 如果是击杀英雄获取的经验，那么直接不给经验，在击杀的事件监听里面处理了
    -- 
    if reason == 1 then
        filterTable.experience = 0
    end

    return true
end

---------------------------------------------------------------------------------
-- 金币过滤器
---------------------------------------------------------------------------------
function GameMode:ModifyGoldFilter(filterTable)
    local reason = filterTable.reason_const
    local reliable = filterTable.reliable
    local gold = filterTable.gold
    local payer_id = filterTable.player_id_const

    if GameRules.FightingArea and reason == DOTA_ModifyGold_HeroKill then
        if GameRules.FightingArea:GetRescaleState() == 0 then
            filterTable.gold = gold * 0.85
        end
        if GameRules.FightingArea:GetRescaleState() == 1 then
            filterTable.gold = gold * 0.95
        end
        if GameRules.FightingArea:GetRescaleState() == 2 then
            filterTable.gold = gold * 1.00
        end
        if GameRules.FightingArea:GetRescaleState() == 3 then
            filterTable.gold = gold * 1.05
        end
    end

    return true
end

---------------------------------------------------------------------------------
-- 指令过滤器
---------------------------------------------------------------------------------
function GameMode:OrderFilter(filterTable)
    local orderType = filterTable["order_type"]

    local target = EntIndexToHScript(filterTable.entindex_target)
    local hero = EntIndexToHScript(filterTable.units['0'])
    local order_type = filterTable["order_type"]

    hero.__vLastOrder = filterTable

    if filterTable.entindex_ability and order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
        if table.contains({
            1504, 1505, -- 加星 随星
            1502, 1500, -- 技能点 移除技能
            4096, -- 自爆
            4097,4098,4099
            }, filterTable.entindex_ability)
            then

            if not hero:IsAlive() then
                msg.bottom('#cannot_purchase_this_item_while_dead', hero:GetPlayerID())
                return false
            else
            end
        end
    end

    if filterTable.entindex_ability and order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
        if filterTable.entindex_ability == 4096 then
            if hero.__bSuiciding then return false end
            if hero.__nSuicideCount and hero.__nSuicideCount >= 10 then return false end

            if not hero.__DoubleSuicideConfirm then
                msg.bottom("#purchase_again_to_confirm", hero:GetPlayerID(), nil, "General.PingWarning")
                hero.__DoubleSuicideConfirm = true
                return
            end
            hero.__DoubleSuicideConfirm = nil
            
            msg.bottom("#suicide_in_20_seconds", hero:GetPlayerID(), nil, "General.PingDefense")
            hero.__bSuiciding = true
            Timer(20, function()
                hero.__bSuiciding = false
                if hero:IsAlive() then
                    hero.__nSuicideCount = hero.__nSuicideCount or 0
                    hero.__nSuicideCount = hero.__nSuicideCount + 1
                    hero.__hLastDamageHero = hero.__hLastDamageHero or hero
                    ApplyDamage({
                        attacker = hero.__hLastDamageHero,
                        victim = hero,
                        damage = hero:GetMaxHealth() * 2,
                        damage_type = DAMAGE_TYPE_PURE,
                    })
                end
            end)
            return false
        end

        -- 交换技能位置
        if filterTable.entindex_ability == 4097 then
            local ability1 = hero:GetAbilityByIndex(0):GetAbilityName()
            local ability2 = hero:GetAbilityByIndex(1):GetAbilityName()
            hero:SwapAbilities(ability1, ability2, true, true)
            return false
        end

        if filterTable.entindex_ability == 4098 then
            local ability1 = hero:GetAbilityByIndex(1):GetAbilityName()
            local ability2 = hero:GetAbilityByIndex(2):GetAbilityName()
            hero:SwapAbilities(ability1, ability2, true, true)
            return false
        end

        if filterTable.entindex_ability == 4099 then
            -- 只有智力英雄可以替换34技能的位置
            if hero:GetPrimaryAttribute() ~= DOTA_ATTRIBUTE_INTELLECT then
                return false
            end
            local ability1 = hero:GetAbilityByIndex(2):GetAbilityName()
            local ability2 = hero:GetAbilityByIndex(3):GetAbilityName()
            hero:SwapAbilities(ability1, ability2, true, true)
            return false
        end
    end

    if ( orderType ~= DOTA_UNIT_ORDER_PICKUP_ITEM or filterTable["issuer_player_id_const"] == -1 ) then
        return true
    else
        local player = PlayerResource:GetPlayer(filterTable["issuer_player_id_const"])
        local hero = player:GetAssignedHero()

        local item = EntIndexToHScript( filterTable["entindex_target"] )
        if item == nil then
            return true
        end
        local pickedItem = item:GetContainedItem()
        if pickedItem == nil then
            return true
        end
        local itemName = pickedItem:GetAbilityName()
        if itemName == "item_treasure_chest" then
            if hero:GetNumItemsInInventory() < 9 then
                return true
            else
                local position = item:GetAbsOrigin()
                filterTable["position_x"] = position.x
                filterTable["position_y"] = position.y
                filterTable["position_z"] = position.z
                filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
                return true
            end
        end

        -- 如果玩家在装备已满的情况下拾取技能，如果玩家拥有技能，那么直接为玩家添加技能
        if hero:GetNumItemsInInventory() >= 9 
            and table.contains(GameRules.RandomDropAbilityScrolls, itemName) 
            and not hero:HasItemInInventory(itemName) then
            
            local abilityName = string.sub(itemName, 6)
            
            local function autoLevelAbility()
                local ability = hero:FindAbilityByName(abilityName)
                if ability:GetLevel() < hero:GetLevel() and ability:GetLevel() < ability:GetMaxLevel() then
                    ability:UpgradeAbility(false)
                    UTIL_Remove(item)
                end
            end

            local function moveToItem()
                local position = item:GetAbsOrigin()
                filterTable["position_x"] = position.x
                filterTable["position_y"] = position.y
                filterTable["position_z"] = position.z
                filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
            end

            if hero:HasAbility(abilityName) then
                if (hero:GetOrigin() - item:GetAbsOrigin()):Length2D() < 128 then
                    autoLevelAbility()
                    return false
                else
                    moveToItem()
                    Timer(function()
                        -- 如果下达了其他指令，那么就不去拾取物品了
                        if hero.__vLastOrder ~= filterTable then return nil end
                        if (hero:GetOrigin() - item:GetAbsOrigin()):Length2D() < 128 then
                            autoLevelAbility()
                            return nil
                        end

                        return 0.03
                    end)
                    return true
                end
            else
                moveToItem()
                return true
            end
            
        end
    end
    return true
end
---------------------------------------------------------------------------------
-- 初始化游戏事件监听
---------------------------------------------------------------------------------
function GameMode:SetupGameEventListener()
    ListenToGameEvent("player_chat",Dynamic_Wrap(GameMode, "OnPlayerChat"),self)
    ListenToGameEvent("npc_spawned",Dynamic_Wrap(GameMode, "OnNpcSpawned"),self)
    ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( GameMode, 'OnGameRulesStateChange' ), self )
    ListenToGameEvent("entity_killed", Dynamic_Wrap(GameMode, "OnEntityKilled"), self)
    ListenToGameEvent( "player_connect_full", Dynamic_Wrap(GameMode, "OnPlayerConnectFull"), self)
end

---------------------------------------------------------------------------------
-- 当玩家连接完成
-- map玩家的userid和playerid
---------------------------------------------------------------------------------
function GameMode:OnPlayerConnectFull(keys)
    GameRules.userid2player = GameRules.userid2player or {}
    GameRules.userid2player[keys.userid] = keys.index+1
end

---------------------------------------------------------------------------------
-- 说话指令
---------------------------------------------------------------------------------
function GameMode:OnPlayerChat(keys)
    if IsInToolsMode() then
        self:Debug_OnPlayerChat(keys)
    end

    local text = keys.text
    local playerId = keys.playerid
    local player = PlayerResource:GetPlayer(playerId)
    local hero = player:GetAssignedHero()
    -- {s:player_name}你已经使用了
    -- {d:num_normal_book}本普通技能书和
    -- {d:num_ultimate_book}本终极技能书。
    if text == "book" then

        local team = hero:GetTeamNumber()
        if keys.teamonly ~= 1 then
            team = -1
        end

        local gameEvent = {
            player_id = playerId,
            int_value = hero.__nNumNormalBook__ or 0,
            teamnumber = team,
            message = "#GameMessage_BookUsedNormal",
        }
        FireGameEvent( "dota_combat_event_message", gameEvent )
        gameEvent.int_value = hero.__nNumUltimateBook__ or 0
        gameEvent.message = "#GameMessage_BookUsedUltimate"
        FireGameEvent( "dota_combat_event_message", gameEvent )
    end

    local code = string.lower(string.trim(text))
    if string.startswith(code, 'bom') and string.len(code) == 39 then
        local steamid = PlayerResource:GetSteamAccountID(playerId)
        local req = CreateHTTPRequestScriptVM('POST', 'http://yueyutech.com:10011/ActivateCode')
        req:SetHTTPRequestGetOrPostParameter('steamid', tostring(steamid))
        req:SetHTTPRequestGetOrPostParameter('code', tostring(code))
        req:Send(function(result)
            local gameEvent = {
                player_id = playerId,
                int_value = 0,
                teamnumber = hero:GetTeamNumber(),
                message = "#GameMessage_ChargeFailed",
            }
            if result.StatusCode == 200 then
                gameEvent.message = "#GameMessage_ChargeSuccess"
                gameEvent.int_value = tonumber(result.Body)
            else
                gameEvent.message = "#GameMessage_ChargeFailed_" .. result.StatusCode
            end
            FireGameEvent( "dota_combat_event_message", gameEvent )
            GameRules.EconManager:OnPlayerAskPointHistory({
                PlayerID = playerId
            })
        end)
    end
end

---------------------------------------------------------------------------------
-- 当玩家出生
---------------------------------------------------------------------------------
function GameMode:OnNpcSpawned(keys)
    local hSpawnedUnit = EntIndexToHScript( keys.entindex )
    if hSpawnedUnit:IsRealHero() then
        self:PutStartPositionToRandomPosForTeam(hSpawnedUnit:GetTeamNumber())
        Timer(0, function()
            if not hSpawnedUnit.__bInited then
                Timer(RandomFloat(0, 0.3), function()
                    if not hSpawnedUnit.__bInited then
                        self:InitPlayerHero(hSpawnedUnit)
                    end
                end)
            else
                hSpawnedUnit:AddNewModifier(hSpawnedUnit,nil,"modifier_respawn_bonus",{})
            end
        end)
        
        -- 添加真视
        hSpawnedUnit:AddNewModifier(hSpawnedUnit, nil, 'modifier_bom_truesight', {Radius = 800})

        if not hSpawnedUnit:HasModifier('modifier_daytime_vision_range_bonus') then
            hSpawnedUnit:AddNewModifier(hSpawnedUnit, nil, 'modifier_daytime_vision_range_bonus', {})
        end

        if not hSpawnedUnit:HasModifier("modifier_disconnect_detection") and not IsInToolsMode() then
            hSpawnedUnit:AddNewModifier(hSpawnedUnit,nil,"modifier_disconnect_detection",{})
        end

        -- 添加逃兵之耻??
        -- 应当慎重
        if GameRules.vDCTData and GameRules.vDCTData[hSpawnedUnit:GetPlayerID()] then
            local dct = GameRules.vDCTData[hSpawnedUnit:GetPlayerID()]
            if dct > 5 then
                local modifierName = "modifier_shame_of_deserter_tooltip"
                local stackCount = dct
                if dct > 20 then
                    modifierName = "modifier_shame_of_deserter"
                    stackCount = dct - 20
                end
                if not hSpawnedUnit:HasModifier(modifierName) then
                    hSpawnedUnit:AddNewModifier(hSpawnedUnit, nil, modifierName, {})
                end
                hSpawnedUnit:SetModifierStackCount(modifierName, hSpawnedUnit, stackCount)
            end
        end
    end
end

---------------------------------------------------------------------------------
-- 这两个函数是新的技能卷轴掉落算法
---------------------------------------------------------------------------------
-- 修改为类似播放列表的循环机制
-- 避免玩家有太差的游戏体验
-- 
-- 1. 构建一个随机掉落列表
-- 2. 对该表进行随机洗牌
-- 3. 每次获取表的最后一个元素
-- 4. 如果该表为空，那么重新构建一个表
-- 
function GameMode:BuildnxAbilityScrollDropTable()
    -- 一个新的平衡性常数，用来定义循环掉落表的大小，这个数值越大，那么随机程度越高
    local n = 80 -- 只要掉落了这么多个技能卷轴，那么每个技能卷轴都会至少出现一次
    local ret = {}
    for _, scroll in pairs(GameRules.RandomDropAbilityScrolls) do
        -- 每个元素都至少出现一次
        table.insert(ret, scroll)
    end
    for i = 1, n - table.count(GameRules.RandomDropAbilityScrolls) do
        -- 其他的元素掉落则纯随机
        local item = table.random(GameRules.RandomDropAbilityScrolls)
        table.insert(ret, item)
    end

    return ret
end
-- 获取下一个掉落技能卷轴的时候，以数字id为索引
function GameMode:GetNextListRandomAbilityScroll(id)
    if GameRules['AbilityScrollDropTable' .. id] == nil or -- 尚未创建过或者创建的表用完了，那么就重新创建一个
        table.count(GameRules['AbilityScrollDropTable' .. id]) <= 0 then
        GameRules['AbilityScrollDropTable' .. id] = self:BuildnxAbilityScrollDropTable()
    end

    local count = table.count(GameRules['AbilityScrollDropTable' .. id])
    local element = GameRules['AbilityScrollDropTable' .. id][count]
    GameRules['AbilityScrollDropTable' .. id][count] = nil
    return element
end

---------------------------------------------------------------------------------
-- 当单位被击杀
---------------------------------------------------------------------------------
function GameMode:OnEntityKilled(keys)
    local hKilled = EntIndexToHScript(keys.entindex_killed)
    local hAttacker = EntIndexToHScript(keys.entindex_attacker)

    -- 如果是英雄
    if hKilled:IsRealHero() then
        hKilled:SetTimeUntilRespawn(5)
        Timer(4.8, function()
            self:PutStartPositionToRandomPosForTeam(hKilled:GetTeamNumber(), hKilled:GetOrigin())
        end)
    end

    -- 如果被玩家击杀，那么得分
    if hAttacker:IsControllableByAnyPlayer() and hKilled:IsRealHero() then
        self:UpdateScoreboard()

        local team = hAttacker:GetTeamNumber()
        hAttacker.flLastKillTime = GameRules:GetGameTime()

        -- sf的特效
        if hAttacker.__bSFWingsParticle then
            EconCreateParticleOnHero(hAttacker, "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_wings.vpcf")
        end

        -- 击杀涂鸦
        if hAttacker.__PszKillMarkParticle then
            local pid = ParticleManager:CreateParticle(hAttacker.__PszKillMarkParticle,PATTACH_WORLDORIGIN,hAttacker)
            ParticleManager:SetParticleControl(pid,0,hKilled:GetAbsOrigin())
            ParticleManager:SetParticleControlForward(pid,0,RandomVector(1))
            ParticleManager:ReleaseParticleIndex(pid)
        end

        -- 如果是连续击杀 获得特效
        local streak = hAttacker:GetStreak()
        if streak >= 3 then
            if streak > 10 then
                streak = 10
            end
            local pid = ParticleManager:CreateParticle("particles/kill_streak/kill_streak_" .. tostring(streak) .. ".vpcf",PATTACH_OVERHEAD_FOLLOW,hAttacker)
            ParticleManager:SetParticleControlEnt(pid,0,hAttacker,PATTACH_OVERHEAD_FOLLOW,"follow_overhead",hAttacker:GetOrigin(),true)
        end

        -- 经验值平均分配给范围内的英雄
        local level = hKilled:GetLevel()
        if level < 1 then level = 1 end
        if level > 25 then level = 25 end
        local exp = ({
            30, 60, 90, 120, 150, 200, 220, 330, 440, 550, 660, 770, 880, 990, 1100, 1210, 1320, 1430, 1540, 1650, 1760, 1870, 1980, 2090, 2200
        })[level]
        local heroes = FindUnitsInRadius(hKilled:GetTeamNumber(), hKilled:GetOrigin(), nil, 1200, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

        local teammates = {}
        for _, hero in pairs(heroes) do
            if hero:GetTeamNumber() == hAttacker:GetTeamNumber() then
                table.insert(teammates, hero)
            end
        end

        local count = #teammates
        exp = exp / count
        for _, hero in pairs(teammates) do
            hero:AddExperience(exp, 0, false, false)
        end
    end

    -- 如果是野怪
    if hKilled:IsCreature() or hKilled:IsNeutralUnitType() then

        local hasAbilityScrollDrop = false

        local abilityScrollDropRate = 3
        local ABILITY_SCROLL_DROP_RATE = {
            {13*60, 38}, -- 在这个时间节点之前，爆率为V[2]的数值
            { 9*60, 25},
            { 5*60, 10},
        }

        for k,v in ipairs(ABILITY_SCROLL_DROP_RATE) do
            if GameRules.nCountDownTimer > v[1] then -- 在这个时间节点之前，爆率为V[2]的数值
                abilityScrollDropRate = v[2]
                break
            end
        end

        if RollPercentage(abilityScrollDropRate) then
            -- local dropItem = table.random(GameRules.RandomDropAbilityScrolls)

            -- 改用了新的列表随机的循环方式
            local id = 99 -- 事先赋值一个无效值是为了避免非玩家单位击杀的情况下出错
            if hAttacker.GetPlayerID then
                id = hAttacker:GetPlayerID()
            end

            local dropItem = self:GetNextListRandomAbilityScroll(id)

            utilsBonus.DropLootItem(dropItem, hKilled:GetOrigin(), 10)

            hasAbilityScrollDrop = true
        end

        local spellBookDropRate = 14
        local SPELL_BOOK_DROP_RATE = {
            {13*60, 8.5 }, -- 在这个时间节点之前，爆率为V[2]的数值
            { 9*60, 10 },
            { 5*60, 12},
        }

        local ultimateSpellbookDropRate = 28 -- 在掉落的技能书中，终极技能书所占的比例
        for k,v in ipairs(SPELL_BOOK_DROP_RATE) do
            if GameRules.nCountDownTimer > v[1] then -- 在这个时间节点之前，爆率为V[2]的数值
                spellBookDropRate = v[2]
                break
            end
        end

        if hAttacker:HasModifier('modifier_fearless_brave') then
            spellBookDropRate = spellBookDropRate + hAttacker:FindModifierByName('modifier_fearless_brave'):GetStackCount()
        end
        
        if hAttacker:HasModifier('modifier_shame_of_deserter') then
            -- 暂时不真的减
            -- spellBookDropRate = spellBookDropRate - 0.1 * hAttacker:FindModifierByName('modifier_shame_of_deserter'):GetStackCount()
        end

        if RollPercentage(spellBookDropRate) then
            local dropItem = "item_spellbook_normal"
            if RollPercentage(ultimateSpellbookDropRate) then
                dropItem = "item_spellbook_ultimate"
            end

            local dropRadius = 10
            if hasAbilityScrollDrop then dropRadius = 100 end
            utilsBonus.DropLootItem(dropItem, hKilled:GetOrigin(), dropRadius)
        end
    end
end

---------------------------------------------------------------------------------
-- 初始化玩家英雄
---------------------------------------------------------------------------------
function GameMode:InitPlayerHero( hero )
    -- 移除除了天赋树技能之外的全部技能
    -- 要记住天赋的顺序
    hero.__bInited = true
    for i = 0, 23 do
        local ability = hero:GetAbilityByIndex(i)
        if ability then
            local name = ability:GetAbilityName()
            if not string.find(name, "special_bonus") then
                hero:RemoveAbility(name)
            end
        end
    end

    -- 为玩家添加所有的空技能
    local empty_abilities = {
        'empty_a1', -- 4个购买技能？
        'empty_a2',
        'empty_a3',
        'empty_a4', -- 4,5两个技能会隐藏
        'empty_a5', -- 4,5两个技能会隐藏
        'empty_a6',
        'empty_1', -- 6个随机掉落技能
        'empty_2',
        'empty_3',
        'empty_4',
        'empty_5',
        -- 'empty_6',
    }

    if hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
        table.insert(empty_abilities, "empty_6")
    end

    for _, name in ipairs(empty_abilities) do
        hero:AddAbility(name)
        hero:FindAbilityByName(name):SetLevel(1)
    end

    -- 对英雄的技能进行排序，如果顺序不对，那么就从后面找到这个技能，排序排对
    -- 这个部分是为了让技能顺序正确，很多东西都依赖于这个
    -- 不要再瞎JB改了！
    for i = 0, 20 do
        local ability = hero:GetAbilityByIndex(i)
        if ability then
            local abilityName = ability:GetAbilityName()
            if abilityName ~= empty_abilities[i+1] then
                hero:SwapAbilities(empty_abilities[i+1],abilityName,true,true)
            end
        end
    end

    -- 星星系统初始化
    GameRules.StarSystem:Init(hero)

    -- 设置所有英雄的基础攻击间隔都为1.5
    -- upodate
    -- 近战1.5，远程1.6
    if hero:IsRangedAttacker() then
        hero:SetBaseAttackTime(1.6000)
    else
        hero:SetBaseAttackTime(1.5000)
    end

    -- 移除默认送的TP
    local tp = hero:FindItemInInventory('item_tpscroll')
    if tp then
        tp:RemoveSelf()
    end

    -- 为了积分而记录
    GameRules.vHeroesForRating = GameRules.vHeroesForRating or {}
    GameRules.vHeroesForRating[hero] = {}

    -- 如果还在没开始的时候，给英雄添加无敌
    if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        hero:AddNewModifier(hero, nil, 'modifier_invulnerable', {Duration=60})
    end

    -- 禁用背包物品的CD
    if not hero._itemFixerTimer then
        hero._itemFixerTimer = true
        Timer(0, function()
            for i = 0, 5 do
                local item = hero:GetItemInSlot(i)
                if item and item:GetItemState() ~= 1 then
                    item:SetItemState(1)
                end
            end
            return 0.03
        end)
    end

    Timer(0.1, function()
        GameRules.EconManager:OnPlayerAskCollection({
            PlayerID = hero:GetPlayerID()    
        })
    end)

    -- 增强某些英雄的天赋
    local function swapTalentsSafe(t1, t2)
        if hero:HasAbility(t1) and hero:HasAbility(t2) then
            hero:SwapAbilities(t1, t2, true, true)
        end
    end
    local function replaceTalentSafe(to, tr)
        if hero:HasAbility(to) then
            hero:AddAbility(tr)
            hero:SwapAbilities(tr, to, true, false)
            hero:RemoveAbility(to)
        end
    end
    -- 水晶室女
    if hero:GetUnitName() == "npc_dota_hero_crystal_maiden" then
        swapTalentsSafe('special_bonus_attack_speed_250', 'special_bonus_unique_crystal_maiden_1')
    end
    -- 凤凰
    if hero:GetUnitName() == "npc_dota_hero_phoenix" then
        swapTalentsSafe('special_bonus_spell_amplify_8', 'special_bonus_unique_phoenix_3')
        swapTalentsSafe('special_bonus_hp_500', 'special_bonus_unique_phoenix_4')
    end
    -- 维萨吉
    if hero:GetUnitName() == "npc_dota_hero_visage" then
        swapTalentsSafe('special_bonus_cast_range_125', 'special_bonus_exp_boost_40')
        swapTalentsSafe('special_bonus_cast_range_125', 'special_bonus_unique_visage_5')
    end
    -- 陈
    if hero:GetUnitName() == "npc_dota_hero_chen" then
        swapTalentsSafe("special_bonus_cast_range_200", "special_bonus_unique_chen_1")
    end
    -- 死亡先知
    if hero:GetUnitName() == "npc_dota_hero_death_prophet" then
        swapTalentsSafe("special_bonus_cast_range_150", "special_bonus_unique_death_prophet_2")
    end
    -- 谜团

    if hero:GetUnitName() == "npc_dota_hero_enigma" then
        swapTalentsSafe("special_bonus_gold_income_25", "special_bonus_unique_enigma_3")
    end
    -- 死灵飞龙 将一个天赋修改为200的施法距离
    if hero:GetUnitName() == "npc_dota_hero_winter_wyvern" then
        replaceTalentSafe('special_bonus_unique_winter_wyvern_2', 'special_bonus_cast_range_200')
    end
end

---------------------------------------------------------------------------------
-- 游戏阶段变更
---------------------------------------------------------------------------------
function GameMode:OnGameRulesStateChange()
    local newState = GameRules:State_Get()
    if newState == DOTA_GAMERULES_STATE_PRE_GAME then
        self:UpdateAbilityPoolToClient()

        if GameRules.bFreeModeActivated == true then
            local gameEvent = {
                player_id = playerId,
                teamnumber = -1,
                message = "#GameMessageFreeModeActivated",
            }
            FireGameEvent( "dota_combat_event_message", gameEvent )
            FireGameEvent( "dota_combat_event_message", gameEvent )
            FireGameEvent( "dota_combat_event_message", gameEvent )
        end
    end

    if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        GameRules.nCountDownTimer = 30 * 60 + 60

        local options = {
            option1 = 40,
            option2 = 50,
            option2 = 60,
            time_limit = GameRules.nCountDownTimer,
        }

        self.TEAM_KILLS_TO_WIN = 50
        if GetMapName() == "arena_1x10" then
            options = {
                option1 = 40,
                option2 = 50,
                option3 = 60,
                time_limit = GameRules.nCountDownTimer,
            }
        elseif GetMapName() == "arena_2x6" then
            options = {
                option1 = 60,
                option2 = 70,
                option3 = 80,
                time_limit = GameRules.nCountDownTimer,
            }
        elseif GetMapName() == "arena_3x4" then
            options = {
                option1 = 85,
                option2 = 100,
                option3 = 115,
                time_limit = GameRules.nCountDownTimer,
            }
        elseif GetMapName() == "arena_4x3" then
            options = {
                option1 = 90,
                option2 = 110,
                option3 = 130,
                time_limit = GameRules.nCountDownTimer,
            }
        elseif GetMapName() == "arena_5v5" then
            options = {
                option1 = 70,
                option2 = 100,
                option3 = 130,
                time_limit = GameRules.nCountDownTimer,
            }
        end

        CustomNetTables:SetTableValue("game_state", "vote_options", options)
        self.voteOptions = options
    end

    if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then

        self:CalculateVoteResult()

        -- 为每个玩家创建随机英雄
        Timer(0.1, function()
            for i = 0, DOTA_MAX_TEAM_PLAYERS do
                Timer(function()
                    local player = PlayerResource:GetPlayer(i)
                    if player and PlayerResource:IsValidTeamPlayer(i) then
                        player:MakeRandomHeroSelection()

                        -- 给玩家三选一的机会
                        Timer(1, function()

                            if GameRules:IsGamePaused() then return 0.03 end

                            local hero = player:GetAssignedHero()

                            if not hero then return 0.03 end

                            Timer(function()
                                if not IsValidAlive(hero) then hero:RespawnHero(false, false) end
                            end)

                            Timer(RandomFloat(0, 0.3), function()
                                if not hero.__bInited then
                                    self:InitPlayerHero(hero)
                                end
                            end)

                            -- 把英雄的技能加到技能池中
                            local heroName = hero:GetUnitName()
                            local heroData = GameRules.OriginalHeroes[heroName]
                            local orignalHeroAbilities = {}
                            local hero_abilities = {}
                            for abilityIndex = 1, 10 do
                                local abilityName = heroData['Ability' .. abilityIndex]
                                if abilityName then
                                    if GameRules.OriginalAbilities[abilityName] 
                                        and GameRules.OriginalAbilities[abilityName].AbilityType ~= "DOTA_ABILITY_TYPE_ATTRIBUTES" 
                                        and not table.contains(GameRules.vBlackList, abilityName) 
                                        then
                                        if GameRules.OriginalAbilities[abilityName].AbilityType ~= "DOTA_ABILITY_TYPE_ULTIMATE" then
                                            if not table.contains(GameRules.vNormalAbilitiesPool, abilityName) then
                                                table.insert(GameRules.vNormalAbilitiesPool, abilityName)
                                                table.insert(hero_abilities, abilityName)
                                            end
                                        else
                                            if not table.contains(GameRules.vUltimateAbilitiesPool, abilityName) then
                                                table.insert(GameRules.vUltimateAbilitiesPool, abilityName)
                                                table.insert(hero_abilities, abilityName)
                                            end
                                        end

                                    end
                                end
                            end

                            table.insert(GameRules.vHeroAbilityPoolForPlus, {
                                hero = heroName, abilities = hero_abilities
                            })


                            self:UpdateAbilityPoolToClient();

                            -- 显示随机英雄面板
                            self:ShowRandomHeroSelection(i)
                        end)
                        return nil
                    end
                    return 0.1
                end)
            end
        end)
    end

    if newState == DOTA_GAMERULES_STATE_PRE_GAME then

        local numberOfPlayers = PlayerResource:GetPlayerCount()

        if not self.bCountDownTimer then
            self.bCountDownTimer = true
            Timer(1, function()
                if GameRules:IsGamePaused() then return 1 end
                
                GameRules.nCountDownTimer = GameRules.nCountDownTimer - 1
                self:UpdateTimer()
                if GameRules.nCountDownTimer == 30 then
                    CustomGameEventManager:Send_ServerToAllClients( "timer_alert", {} )
                end
                if GameRules.nCountDownTimer <= 0 then
                    if self.isGameTied == false then
                        self:EndGame( self.leadingTeam )
                        self.countdownEnabled = false
                    else
                        self.TEAM_KILLS_TO_WIN = self.leadingTeamScore + 1
                        local broadcast_killcount = 
                        {
                            killcount = self.TEAM_KILLS_TO_WIN
                        }
                        CustomGameEventManager:Send_ServerToAllClients( "overtime_alert", broadcast_killcount )
                    end
                end
                return 1
            end)
        end

        self._fPreGameStartTime = GameRules:GetGameTime()
    end

    if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )

        -- 在游戏开始的时候进入第一个夜晚
        -- 0.75 = 夜晚开始的时间
        -- 0.25 = 白天开始的时间
        GameRules:SetTimeOfDay(0.75)

        -- 移除开局时候的无敌
        for hero in pairs(GameRules.vHeroesForRating) do
            if IsValidAlive(hero) then
                hero:RemoveModifierByName('modifier_invulnerable')
            end
        end
    end
end

---------------------------------------------------------------------------------
-- 结束游戏
---------------------------------------------------------------------------------
function GameMode:EndGame(winner)
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return
    end
    GameRules:SetGameWinner(winner or DOTA_TEAM_GOODGUYS)
end

---------------------------------------------------------------------------------
-- 更新积分板
---------------------------------------------------------------------------------
function GameMode:UpdateScoreboard()
    local sortedTeams = {}
    local teams = {2,3,6,7,8,9,10,11,12,13}
    for i = 1, GameRules.GameMode.nTeamCount do
        table.insert(sortedTeams, {
            teamID = teams[i],
            teamScore = GetTeamHeroKills( teams[i] )
        })
    end

    -- reverse-sort by score
    table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )
    
    local leader = sortedTeams[1].teamID
    self.leadingTeam = leader
    self.runnerupTeam = sortedTeams[2].teamID
    self.leadingTeamScore = sortedTeams[1].teamScore
    self.runnerupTeamScore = sortedTeams[2].teamScore

    -- 如果有队伍达到了胜利的条件，那么设置他胜利
    if self.leadingTeamScore >= self.TEAM_KILLS_TO_WIN then
        self:EndGame(self.leadingTeam)
    end

    if sortedTeams[1].teamScore == sortedTeams[2].teamScore then
        self.isGameTied = true
    else
        self.isGameTied = false
    end
    local allHeroes = HeroList:GetAllHeroes()

    local leaderHeroes = {}
    local otherTeamHeroes = {}

    for _,entity in pairs( allHeroes) do
        if entity:GetTeamNumber() == leader and sortedTeams[1].teamScore ~= sortedTeams[2].teamScore then
            if entity:IsAlive() == true then
                local existingParticle = entity:Attribute_GetIntValue( "particleID", -1 )
                if existingParticle == -1 then
                    local particleLeader = ParticleManager:CreateParticle( "particles/leader/leader_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, entity )
                    ParticleManager:SetParticleControlEnt( particleLeader, PATTACH_OVERHEAD_FOLLOW, entity, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", entity:GetAbsOrigin(), true )
                    entity:Attribute_SetIntValue( "particleID", particleLeader )
                end
            else
                local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
                if particleLeader ~= -1 then
                    ParticleManager:DestroyParticle( particleLeader, true )
                    entity:DeleteAttribute( "particleID" )
                end
            end
            table.insert(leaderHeroes, entity)
        else
            table.insert(otherTeamHeroes, entity)
            local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
            if particleLeader ~= -1 then
                ParticleManager:DestroyParticle( particleLeader, true )
                entity:DeleteAttribute( "particleID" )
            end
        end
    end

    -- 在开始缩小战斗区域之后，排名靠后的玩家会根据排名叠加
    -- 勇者无畏buff，每层可以降低自身所受到的伤害5%；
    if GameRules.nCountDownTimer < 20 * 60 then
        local buffTeams = {}
        if GetMapName() == "arena_1x10" then
            -- 单人 7 8 9 10名加 5% 10% 15% 15%
            buffTeams[4] = 1
            buffTeams[5] = 1
            buffTeams[6] = 2
            buffTeams[7] = 3
            buffTeams[8] = 4
            buffTeams[9] = 5
            buffTeams[10] = 6
        end

        if GetMapName() == "arena_2x6" then
            -- 双人 4 5 6 加5% 10% 10%
            buffTeams[3] = 2
            buffTeams[4] = 3
            buffTeams[5] = 4
            buffTeams[6] = 6
        end

        if GetMapName() == "arena_3x4" then
            -- 三人 3 4 最后一名加 5% 10%
            buffTeams[3] = 3
            buffTeams[4] = 5
        end

        if GetMapName() == "arena_4x3" then
            -- 三人 3 4 最后一名加 5% 10%
            buffTeams[2] = 2
            buffTeams[3] = 4
        end

        -- 先全部移除再加上？
        for _, hero in pairs(allHeroes) do
            hero.__nFearlessBraveCount = 0
        end

        for index, buffCount in pairs(buffTeams) do
            if sortedTeams[index] then
                for _, hero in pairs(allHeroes) do
                    if hero:GetTeamNumber() == sortedTeams[index].teamID then
                        hero.__nFearlessBraveCount = buffCount
                    end
                end
            end
        end

        for _, hero in pairs(allHeroes) do
            if hero.__nFearlessBraveCount == 0 then
                hero:RemoveModifierByName('modifier_fearless_brave')
            else
                if not hero:HasModifier("modifier_fearless_brave") then
                    hero:AddNewModifier(hero, nil, 'modifier_fearless_brave', {})
                end
                hero:SetModifierStackCount('modifier_fearless_brave', hero, hero.__nFearlessBraveCount)
            end
        end
    end

    -- if GameRules.FightingArea and 
    --     (
    --         GameRules.FightingArea:GetRescaleState() == 1
    --         -- or GameRules.FightingArea:GetRescaleState() == 2
    --     ) 
    --     then
    --     for _, hero in pairs(leaderHeroes) do
    --         for _, h in pairs(otherTeamHeroes) do
    --             hero:AddNewModifier(h, nil, 'modifier_bloodseeker_thirst_vision', {duration=-1, IsHidden=1})
    --             if h:HasModifier('modifier_bloodseeker_thirst_vision') then
    --                 h:RemoveModifierByName('modifier_bloodseeker_thirst_vision')
    --             end
    --         end
    --     end
    -- end
end

---------------------------------------------------------------------------------
-- 获取一个随机的有效点
-- 可以通行的，在战斗区域内的点
---------------------------------------------------------------------------------
function GameMode:GetRandomValidPosition()
    local minx = GetWorldMinX()
    local maxx = GetWorldMaxX()
    local miny = GetWorldMinY()
    local maxy = GetWorldMaxY()
    local function getRandomPos()
        if GameRules.FightingArea and GameRules.FightingArea.rescaleCenter and GameRules.FightingArea.rescaleRadius then
            return GameRules.FightingArea.rescaleCenter + RandomVector(RandomFloat(0, GameRules.FightingArea.rescaleRadius))
        else
            return Vector(RandomFloat(minx, maxx), RandomFloat(miny, maxy), 0)
        end
    end
    local randomPos = getRandomPos()
    if self.worldCenterPos == nil then self.worldCenterPos = Entities:FindByName(nil, "world_center"):GetOrigin() end
    while not GridNav:CanFindPath(self.worldCenterPos,randomPos) do
        randomPos = getRandomPos()
    end
    return randomPos
end

---------------------------------------------------------------------------------
-- 修改队伍分数
-- 尚未实装
---------------------------------------------------------------------------------
function GameMode:ModifyScore(team, score)
    self.vScore = self.vScore or {}
    self.vScore[team] = self.vScore[team] or 0
    self.vScore[team] = self.vScore[team] + score

    CustomGameEventManager:Send_ServerToAllClients("update_team_score",self.vScore)
end

---------------------------------------------------------------------------------
-- PLUS相关 - 更新技能池到客户端
---------------------------------------------------------------------------------
function GameMode:UpdateAbilityPoolToClient()

    table.sort(GameRules.vHeroAbilityPoolForPlus, function(a, b) return a.hero < b.hero end)

    CustomNetTables:SetTableValue('econ_data', 'ability_pool', 
        GameRules.vHeroAbilityPoolForPlus)
    CustomGameEventManager:Send_ServerToAllClients('ability_pool_update', {})
end

