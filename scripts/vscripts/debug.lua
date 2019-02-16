if not IsInToolsMode() then return end -- 测试时候的作弊指令

-- 快速测试模式
function GameMode:EnterDebugMode()
	GameRules:SetCustomGameSetupTimeout(3)
    GameRules:SetCustomGameSetupAutoLaunchDelay(3)
    GameRules:SetPostGameTime(600)
end

function GameMode:Debug_OnPlayerChat(keys)
	local c   = string.split(keys.text)
    local cmd = c[1]

    -- 对某个玩家的英雄造成一定的伤害
    -- damage value playerid
    -- damage 10000 2 
    if cmd == "damage" then
    	local pid = tonumber(c[3])
    	local damage = tonumber(c[2])
    	local cmdPlayerHero = PlayerResource:GetPlayer(0):GetAssignedHero()
    	local hero = PlayerResource:GetPlayer(pid or 0):GetAssignedHero()
    	local damage = c[2]
    	ApplyDamage({
    		attacker = cmdPlayerHero,
    		target = hero,
    		damage = tonumber(damage),
    		damage_type = DAMAGE_TYPE_PURE,
    		damage_flags = DAMAGE_FLAG_NONE,
		})
    end

    -- 更换英雄 ch npc_dota_hero_sniper
    if cmd == 'ch' then
        local heroName = c[2]
        PrecacheUnitByNameAsync(heroName, function() end, 0)
        PlayerResource:ReplaceHeroWith(0, heroName, 89999, 0)
    end

    -- 给技能点数 points 1000
    if cmd == 'points' then
        local hero = PlayerResource:GetPlayer(pid or 0):GetAssignedHero()
        hero:SetAbilityPoints(100)
    end

    -- 英勇无畏的buff fearless 5
    if cmd == 'fearless' then
        local hero = PlayerResource:GetPlayer(pid or 0):GetAssignedHero()
        if not hero:HasModifier("modifier_fearless_brave") then
            hero:AddNewModifier(hero, nil, 'modifier_fearless_brave', {})
        end
        hero:SetModifierStackCount('modifier_fearless_brave', hero, tonumber(c[2] or 2))
    end

    -- 直接结束游戏
    if cmd == "endgame" then
        GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
    end

    -- 显示所有野怪刷怪点的位置
    if cmd == 'spawner' then
        -- for _, spawner in pairs(GameRules.GameMode.vSpawners) do
        --     DebugDrawCircle(spawner:GetOrigin(),Vector(255,0,0),255,64,false,5)
        -- end
        for _, spawner in pairs(GameRules.GameMode.vVolumes) do
            DebugDrawCircle(spawner:GetOrigin(),Vector(0,255,0),255,64,false,5)
            print(spawner:GetName())
        end
    end

    -- 添加技能 ab legion_commander_moment_of_courage
    if cmd == "ab" then
        local abilityName = c[2]
        GameRules.GameMode:OnPlayerSelectAbility({
            AbilityName = abilityName,
            PlayerID = 0,
            AbilityPanelID = DoUniqueString('')
        })
    end

    -- 移除技能 abr legion_commander_moment_of_courage
    -- 一般直接商店买个移除技能就行了
    if cmd == "abr" then
        -- 测试移除技能
        local abilityName = c[2]
        GameRules.GameMode:OnPlayerRemoveAbility({
            PlayerID = 0,
            AbilityName = abilityName,
        })
    end

    -- 给技能书，一次给30,
    -- i bn 普通书
    -- i bu 大招书
    -- i bnc 普通空投
    -- i buc 大招空投
    if cmd == 'i' then
        local hero = PlayerResource:GetPlayer(0):GetAssignedHero()
        local item = c[2]
        if item == 'bn' then
            for i = 1, 30 do
                hero:AddItemByName('item_spellbook_normal')
            end
        end
        if item == 'bu' then
            for i = 1, 30 do
                hero:AddItemByName('item_spellbook_ultimate')
            end
        end
        if item == 'bnc' then
            for i = 1, 30 do
                hero:AddItemByName('item_spellbook_normal_courier')
            end
        end
        if item == 'buc' then
            for i = 1, 30 do
                hero:AddItemByName('item_spellbook_ultimate_courier')
            end
        end
    end

    -- 重置初始技能
    if cmd == "ta" then
        print("ta")
        PlayerResource:GetPlayer(0).vInitialAbility = GameRules.GameMode:RandomInitialAbility()
    end

    -- 刷宝箱
    if cmd == "tr" then
        GameRules.Treasure:ForceSpawnItem()
    end

    -- 更换倒计时剩余时间
    -- dt 1000
    if cmd == "dt" then
        GameRules.nCountDownTimer = tonumber(c[2]) or 40
    end
    
    local cmdPlayerHero = PlayerResource:GetPlayer(0):GetAssignedHero()

    -- 装备某个饰品 eq legion_wings
    if cmd == 'eq' then
        local name = c[2]
        if Econ['OnEquip_' .. name .. '_server'] then
            Econ['OnEquip_' .. name .. '_server'](cmdPlayerHero)
        else
            Say(nil, 'no this item', false)
        end
    end

    -- 移除某个饰品 rm legion_wings
    if cmd == 'rm' then
        local name = c[2]
        if Econ['OnRemove_' .. name .. '_server'] then
            Econ['OnRemove_' .. name .. '_server'](cmdPlayerHero)
        else
            Say(nil, 'no this item', false)
        end
    end

    -- 刷宝箱信使
    if cmd == 'treasure' then
        GameRules.Treasure:WarnItem()
        Timer(5, function()
            GameRules.Treasure:SpawnItem()
        end)
    end

    -- 生成一些可以通行的点并显示出来
    -- todo 目前这个feature并没有实装
    -- 以后可能会实装吧
    -- 主要是因为在地图区域小了之后，可能会有一些意想不到的状况出现
    -- 既然现在一切正常，就先不动
    if cmd == "debug_reload_all_grid" then
        require 'utils.grid_position_finder'
        local positions = require 'data.grid_positions'
        for _, pos in pairs(positions) do
            local x = pos.x
            local y = pos.y
            pos = Vector(x, y, 512)
            DebugDrawCircle(pos, Vector(255,0,0), 255, 32, false, 8888)
        end
    end
end
