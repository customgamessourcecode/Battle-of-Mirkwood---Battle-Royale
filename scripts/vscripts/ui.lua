---------------------------------------------------------------------------------
-- 注册UI js发来的事件的监听
---------------------------------------------------------------------------------
function GameMode:RegisterUIEventListeners()
	CustomGameEventManager:RegisterListener("player_select_ability",function(_, keys)
		self:OnPlayerSelectAbility(keys)
	end)
	CustomGameEventManager:RegisterListener("player_confirm_ability_remove", function(_, keys)
		self:OnPlayerConfirmAbilityRemove(keys)
	end)

	CustomGameEventManager:RegisterListener("player_reselect_hero", function(_, keys)
		self:OnPlayerReselectHero(keys)
	end)
	CustomGameEventManager:RegisterListener("player_cancel_hero_reselect", function(_, keys)
		self:OnPlayerCancelReselectHero(keys)
	end)

	-- CustomGameEventManager:RegisterListener('players_vote_finished', function(_, keys)
	-- 	self:OnPlayerVoteForKills(keys)
	-- end)
	CustomGameEventManager:RegisterListener('player_vote', function(_, keys)
		self:OnPlayerVote(keys)
	end)
	CustomGameEventManager:RegisterListener('player_agree_to_shuffle', function(_, keys)
		self:OnPlayerAgreeToShuffle(keys)
	end)
	CustomGameEventManager:RegisterListener('player_vote_for_free_mode', function(_, keys)
		self:OnPlayerVoteForFreeMode(keys)
	end)


	CustomGameEventManager:RegisterListener('bom_ask_star', function(_, keys)
		self:OnClientAskForStar(keys)
	end)
	CustomGameEventManager:RegisterListener('player_rerandom_hero', function(_, keys)
		self:OnPlayerReRandomHero(keys)
	end)
end

-- 有附属技能的技能
local pairedAbility = {
	shredder_chakram="shredder_return_chakram", 
	shredder_chakram_2="shredder_return_chakram_2",
	elder_titan_ancestral_spirit="elder_titan_return_spirit" , 
	phoenix_icarus_dive="phoenix_icarus_dive_stop" , 
	phoenix_sun_ray="phoenix_sun_ray_stop",
	phoenix_fire_spirits="phoenix_launch_fire_spirit",
	alchemist_unstable_concoction="alchemist_unstable_concoction_throw",
	naga_siren_song_of_the_siren="naga_siren_song_of_the_siren_cancel",
	rubick_telekinesis="rubick_telekinesis_land",
	bane_nightmare="bane_nightmare_end",
	ancient_apparition_ice_blast="ancient_apparition_ice_blast_release",
	wisp_tether="wisp_tether_break",
	pangolier_gyroshell="pangolier_gyroshell_stop",
	-- nyx_assassin_burrow="nyx_assassin_unburrow",
	-- necrolyte_sadist = 	"necrolyte_sadist_stop",
	-- puck_illusory_orb= "puck_ethereal_jaunt",
}
-- 有些技能需要buff计数
local brokenModifierCounts = {
	modifier_shadow_demon_demonic_purge_charge_counter = 3,
	modifier_bloodseeker_rupture_charge_counter = 2,
	modifier_earth_spirit_stone_caller_charge_counter = 6,
	modifier_ember_spirit_fire_remnant_charge_counter = 3,
	modifier_obsidian_destroyer_astral_imprisonment_charge_counter = 1
}
-- 有些技能的modifier需要手动添加modifier
local brokenModifierAbilityMap = {
	shadow_demon_demonic_purge = "modifier_shadow_demon_demonic_purge_charge_counter",
	bloodseeker_rupture = "modifier_bloodseeker_rupture_charge_counter",
	earth_spirit_stone_caller="modifier_earth_spirit_stone_caller_charge_counter",
	ember_spirit_fire_remnant="modifier_ember_spirit_fire_remnant_charge_counter",
	obsidian_destroyer_astral_imprisonment="modifier_obsidian_destroyer_astral_imprisonment_charge_counter"
}
-- 有些技能的modifier需要重载
local brokenPassiveModifierAbilities = {
	drow_ranger_marksmanship = "modifier_drow_ranger_marksmanship",
	juggernaut_blade_dance = "modifier_juggernaut_blade_dance",
	legion_commander_moment_of_courage = "modifier_legion_commander_moment_of_courage",
	axe_counter_helix = "modifier_axe_counter_helix",
	abaddon_frostmourne = "modifier_abaddon_frostmourne",
	monkey_king_jingu_mastery = "modifier_monkey_king_quadruple_tap",
	necrolyte_heartstopper_aura = "modifier_necrolyte_heartstopper_aura",
	lina_fiery_soul = "modifier_lina_fiery_soul",
	visage_gravekeepers_cloak = "modifier_visage_gravekeepers_cloak",

}
---------------------------------------------------------------------------------
-- 玩家选择技能
---------------------------------------------------------------------------------
function GameMode:OnPlayerSelectAbility(keys)
	local abilityName = keys.AbilityName
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	local hero  = player:GetAssignedHero()
	if not hero then return end

	hero.__playerHaveSelectedAbility__ = true

	local id = keys.AbilityPanelID
	player.__vPlayerAbilityPanel__ = player.__vPlayerAbilityPanel__ or {}
	if player.__vPlayerAbilityPanel__[id] then return end
	player.__vPlayerAbilityPanel__[id] = true

	GameRules.vSpellbookRecorder = GameRules.vSpellbookRecorder or {}
	local abilities = GameRules.vSpellbookRecorder[id]
	if not abilities or not table.contains(abilities, abilityName) then
		if not IsInToolsMode() then
			print("this is not abilities from server")
			return
		end
	end
	GameRules.vSpellbookRecorder[id] = nil

	if abilityName == "Cancel" then
		return
	end

	-- 提示玩法无法出晕锤
	if abilityName == "slardar_bash"
		or abilityName == "spirit_breaker_greater_bash"
		or abilityName == "faceless_void_time_lock"
		then
		msg.bottom("#hud_tooltip_cannot_bash", playerID, nil, "General.PingWarning")
	end

	-- 尝试修复marksmanship
	if brokenPassiveModifierAbilities[abilityName] then
		Timer(0.1, function()
			if hero:HasAbility(abilityName) then
				hero:RemoveModifierByName(brokenPassiveModifierAbilities[abilityName])
				hero:AddNewModifier(hero, hero:FindAbilityByName(abilityName), brokenPassiveModifierAbilities[abilityName], {})
			end
		end)
	end


	-- 如果是已经拥有的技能，那么就不添加技能，如果不满级，那么加一级
	if hero:HasAbility(abilityName) then
		local ability = hero:FindAbilityByName(abilityName)
		if ability:GetLevel() < ability:GetMaxLevel() then
			ability:SetLevel(ability:GetLevel() + 1)
		end
		return
	end

	-- 找到一个空白的技能来替换
	local abilityName_Replace
	if table.contains(GameRules.vUltimateAbilitiesPool, abilityName) 
		or table.contains(GameRules.vCourierAbilities_Ultimate, abilityName)
		or (IsInToolsMode() and GameRules.OriginalAbilities[abilityName].AbilityType == "DOTA_ABILITY_TYPE_ULTIMATE")
		then
		if hero:HasAbility("empty_a6") then
			abilityName_Replace = "empty_a6"
		end
	elseif table.contains(GameRules.vNormalAbilitiesPool, abilityName) 
		or table.contains(GameRules.vCourierAbilities_Normal, abilityName)
		or (IsInToolsMode() and GameRules.OriginalAbilities[abilityName].AbilityType ~= "DOTA_ABILITY_TYPE_ULTIMATE")
		then

		local empty_abilities = {
			"empty_a1",
			"empty_a2",
			"empty_a3",
		}

		if hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
			table.insert(empty_abilities, "empty_a4")
		end

		for _, name in pairs(empty_abilities) do
			if hero:HasAbility(name) then
				abilityName_Replace = name
				break
			end
		end
	end

	if abilityName_Replace == nil then 
		msg.bottom("#hud_error_ability_is_full", hero:GetPlayerID())
		return 
	end

	hero:AddAbility(abilityName)
	hero:SwapAbilities(abilityName,abilityName_Replace,true,false)
	local ability = hero:FindAbilityByName(abilityName)
	ability:UpgradeAbility(true)

	-- 记录这个技能替换的技能到底是哪个
	hero._vAbilityNameReplaceMap = hero._vAbilityNameReplaceMap or {}
	hero._vAbilityNameReplaceMap[abilityName] = abilityName_Replace

	-- 有modifier支持的
	if brokenModifierAbilityMap[abilityName] then
		local modifier = hero:FindModifierByName(brokenModifierAbilityMap[abilityName])
		if modifier then
			local stack = brokenModifierCounts[brokenModifierAbilityMap[abilityName]]
			modifier:SetStackCount(stack)
		end
	end

	-- 如果有附技能的，为其添加附技能
	if pairedAbility[abilityName] then
		hero:AddAbility(pairedAbility[abilityName])
		hero:FindAbilityByName(pairedAbility[abilityName]):SetLevel(1)

		-- 记录附属技能也是使用这个技能替换的，这样可以用附属技能来移除技能
		hero._vAbilityNameReplaceMap[pairedAbility[abilityName]] = abilityName_Replace
	end

	hero:RemoveAbility(abilityName_Replace)
end

-- 在拥有这些modifier的时候删除技能，可能会导致游戏崩溃，所以不给删
local gameBreakingModifiers = {
	"modifier_spirit_breaker_charge_of_darkness",
	"modifier_mirana_leap",
	"modifier_morphling_waveform",
	"modifier_slark_pounce",
}

---------------------------------------------------------------------------------
-- 确认技能删除
---------------------------------------------------------------------------------
function GameMode:OnPlayerConfirmAbilityRemove(keys)
	local abilityName = keys.AbilityName
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	local hero  = player:GetAssignedHero()
	if not hero then return end

	hero.__remove_ability_state = nil

	if abilityName == "Canceled" then
		msg.bottom('#CANCELED', playerID, "#00aa0066", "General.PingWarning")
		return 
	end

	-- 如果是死亡状态，不给移除技能
	if not hero:IsAlive() then
		msg.bottom('#cannot_remove_ability_dead', playerID)
		return
	end

	-- 解决一些可能导致游戏崩溃的问题
	for _, modifier in pairs(gameBreakingModifiers) do
		if hero:HasModifier(modifier) then
			msg.bottom("#cannot_remove_this_ability_now", playerID)
			return
		end
	end

	local ability = hero:FindAbilityByName(abilityName)
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local cooldownRemaining = ability:GetCooldownTimeRemaining()
	if abilityName == "pudge_meat_hook" then
		if cooldown - cooldownRemaining < 3 then
			msg.bottom("#cannot_remove_this_ability_now", playerID)
			return
		end
	end

	if table.contains({
			"empty_a1",
			"empty_a2",
			"empty_a3",
			"empty_a4",
			"empty_a5",
			"empty_a6",
			"empty_1",
			"empty_2",
			"empty_3",
			"empty_4",
			"empty_5",
			"empty_6",
		}, abilityName) then
		msg.bottom('cannot_remove_this_ability', playerID)
		return
	end 

	local ability = hero:FindAbilityByName(abilityName)
	
	if not ability then
		msg.bottom("#error_ability_not_exist", playerID)
		return
	end

	abilityName_Replace = nil

	-- 是不是右侧被动技能
	local function isRightHandAbility(pszAbilityName)
		for _, name in pairs(GameRules.RandomDropAbilityScrolls) do
			if string.sub(name, 6) == pszAbilityName then
				return true
			end
		end
		return false
	end

	if isRightHandAbility(abilityName) then
		local empty_abilities = {
			"empty_1",
			"empty_2",
			"empty_3",
			"empty_4",
			"empty_5",
			-- "empty_6",
		}
		if hero:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
			table.insert(empty_abilities, 'empty_6')
		end
		for _, name in pairs(empty_abilities) do
			if not hero:FindAbilityByName(name) then
				abilityName_Replace = name
				break
			end
		end
	else
		abilityName_Replace = hero._vAbilityNameReplaceMap[abilityName]
	end

	if abilityName_Replace == nil 
		or abilityName == "shredder_return_chakram"
		then
		msg.bottom("#error_invalid_ability", playerID)
		return
	end

	hero:AddAbility(abilityName_Replace)
	hero:SwapAbilities(abilityName_Replace,abilityName,true,false)
	local ability = hero:FindAbilityByName(abilityName_Replace)
	if ability then
		ability:SetLevel(1)
	end
	
	-- 在移除前，如果是开关技能的，那么改为关闭
	local abilityRemoved = hero:FindAbilityByName(abilityName)
	if abilityRemoved:IsToggle() then
		if abilityRemoved:GetToggleState() == true then
			abilityRemoved:ToggleAbility()
		end
	end

	-- 移除技能的modifier
	local modifiers = hero:FindAllModifiers()
	for _, modifier in pairs(modifiers) do
		if modifier:GetAbility() == abilityRemoved then
			modifier:Destroy()
		end
	end

	-- 移除搭配的技能
	if pairedAbility[abilityName] then
		hero:RemoveAbility(pairedAbility[abilityName])
	end

	-- 如果是点击附属技能来移除的，那么移除主技能
	if table.reverse(pairedAbility)[abilityName] then
		local modifiers = hero:FindAllModifiers()
		for _, modifier in pairs(modifiers) do
			if modifier:GetAbility() == hero:FindAbilityByName(table.reverse(pairedAbility)[abilityName]) then
				modifier:Destroy()
			end
		end
		hero:RemoveAbility(table.reverse(pairedAbility)[abilityName])
	end

	-- 移除被动的modifier
	for name, abilityData in pairs(GameRules.Abilities_KV) do
		if name == abilityName and abilityData.Modifiers then
			for modifierName in pairs(abilityData.Modifiers) do
				if hero:HasModifier(modifierName) then
					hero:RemoveModifierByName(modifierName)
				end
			end
		end
	end

	-- 清理蜘蛛网
	if abilityName == 'broodmother_spin_web' then
		local ents = Entities:FindAllInSphere(Vector(0,0,0), 99999)
		for _, ent in pairs(ents) do
			if ent.GetName and ent:GetName() == "npc_dota_broodmother_web" and ent:GetOwner() == hero
				then
				UTIL_Remove(ent)
			end
		end
	end

	hero:RemoveAbility(abilityName)
end

---------------------------------------------------------------------------------
-- 更新倒计时
---------------------------------------------------------------------------------
function GameMode:UpdateTimer()
    local t = GameRules.nCountDownTimer
    --print( t )
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local daytime = false
    if GameRules.IsDaytime and GameRules:IsDaytime() then
    	daytime = true
    end
    local broadcast_gametimer = 
        {
            timer_minute_10 = m10,
            timer_minute_01 = m01,
            timer_second_10 = s10,
            timer_second_01 = s01,
            daytime = daytime
        }
    CustomGameEventManager:Send_ServerToAllClients( "countdown", broadcast_gametimer )
    if t <= 120 then
        CustomGameEventManager:Send_ServerToAllClients( "time_remaining", broadcast_gametimer )
    end
end

---------------------------------------------------------------------------------
-- 显示初始技能面板
---------------------------------------------------------------------------------
function GameMode:ShowInitialAbilityPanel(hero)

	local totalAbilities = 8

	-- 把英雄的技能加到技能池中
	local heroName = hero:GetUnitName()
	local heroData = GameRules.OriginalHeroes[heroName]
	local orignalHeroAbilities = {}
	local hero_abilities = {}

	for i = 1, 10 do
		local abilityName = heroData['Ability' .. i]
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

	self:UpdateAbilityPoolToClient()

	-- 选择初始技能

    local randomAbilities = table.random_some(GameRules.vNormalAbilitiesPool, 8)
    -- 如果包含有附加的特殊技能，那么有大概率替换掉
	for k, ability in pairs(randomAbilities) do
		if table.contains(GameRules.vCourierAbilities_Normal, ability) then
			-- if RollPercentage(60) then
				local randomAbility = table.random(GameRules.vNormalAbilitiesPool)
				while (table.contains(randomAbilities, randomAbility) 
					or table.contains(GameRules.vCourierAbilities_Normal, randomAbility))
					do
					randomAbility = table.random(GameRules.vNormalAbilitiesPool)
				end
				randomAbilities[k] = randomAbility
			-- end
		end
	end
	
    hero.vInitialAbility = hero.vInitialAbility or randomAbilities

	Timer(0, function()
        if not hero.__playerHaveSelectedAbility__ then

        	hero.vInitialAbilityPanelID = hero.vInitialAbilityPanelID or "spell_book_" .. DoUniqueString('')

        	GameRules.vSpellbookRecorder = GameRules.vSpellbookRecorder or {}
			local id = hero.vInitialAbilityPanelID
			GameRules.vSpellbookRecorder[id] = hero.vInitialAbility

            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(hero:GetPlayerID()),"show_ability_selector",{
                ID = hero.vInitialAbilityPanelID,
                Abilities = hero.vInitialAbility,
                Type = "normal"
            })
            return 1
        end
    end)
end

---------------------------------------------------------------------------------
-- 重选英雄
---------------------------------------------------------------------------------
function GameMode:OnPlayerReselectHero(keys)
	local abilityName = keys.AbilityName
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)

	local hero = player:GetAssignedHero()
	if not hero then return end

	if hero.__bReselectedHero__ then return end
	hero.__bReselectedHero__ = true
	if player.__bReselectedHero__ then return end
	player.__bReselectedHero__ = true

	if not table.contains(hero._randomHero, keys.HeroName) then
		if not IsInToolsMode() then
			print("not hero that selected by server")
			return
		end
	end

	-- hero:AddNewModifier(hero, nil, 'modifier_waiting_for_precache', {})
    -- Notifications:Bottom(player, { text = 'hud_tooltip_waiting_for_precache', duration = 5, style = { color = "red", ["font-size"] = "30px", border = "0px" } , continue = continue})
    msg.bottom("#hud_tooltip_waiting_for_precache", playerID, nil, "General.PingWarning")

    local oldHero = hero

	PrecacheUnitByNameAsync(keys.HeroName,function() 
		Timer(function()

			if not PlayerResource:IsValidTeamPlayer(playerID) then return 0.03 end
			if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_CONNECTED then return 0.03 end

			local hero = PlayerResource:ReplaceHeroWith(playerID,keys.HeroName,hero:GetGold(),0)	

			Timer(0.1, function()
				GameRules.EconManager:OnPlayerEquip({
					PlayerID = playerID	
				})
			end)
			Timer(0.5, function()
				if GameRules:IsGamePaused() then return 0.03 end
				self:ShowInitialAbilityPanel(hero)
			end)

			-- 如果是虚空、巨魔、大鱼人，告知玩家这个模型不能出晕锤
		    if table.contains({
		    		"npc_dota_hero_slardar",
		    		"npc_dota_hero_faceless_void",
		    		"npc_dota_hero_troll_warlord",
		    	}, keys.HeroName) then
		    	-- Notifications:Bottom(player, { text = 'hud_tooltip_model_cannot_bash', duration = 5, style = { color = "red", ["font-size"] = "30px", border = "0px" } , continue = continue})
		    	msg.bottom("#hud_tooltip_model_cannot_bash", playerID, nil, "General.PingWarning")
		    end

		  --   Timer(1, function()
		  --   	oldHero:SetOrigin(Vector(99999,99999,0))
				-- oldHero:AddNewModifier(oldHero, nil, "modifier_rooted", {})
				-- oldHero:AddNewModifier(oldHero, nil, "modifier_disarmed", {})
				-- oldHero:AddNewModifier(oldHero, nil, "modifier_invulnerable", {})
		  --   end)
		end)
	end, playerID)
end

---------------------------------------------------------------------------------
-- 取消重选英雄（都不想要）
---------------------------------------------------------------------------------
function GameMode:OnPlayerCancelReselectHero(keys)
	local playerID = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerID)
	if player.__bReselectedHero__ then return end
	player.__bReselectedHero__ = true

	local hero = player:GetAssignedHero()
	Timer(1, function()
		self:ShowInitialAbilityPanel(hero)
	end)

	-- 如果是虚空、巨魔、大鱼人，告知玩家这个模型不能出晕锤
    if table.contains({
    		"npc_dota_hero_slardar",
    		"npc_dota_hero_faceless_void",
    		"npc_dota_hero_troll_warlord",
    	}, hero:GetUnitName()) then
    	Notifications:Bottom(player, { text = 'hud_tooltip_model_cannot_bash', duration = 5, style = { color = "red", ["font-size"] = "30px", border = "0px" } , continue = continue})
    end
end

---------------------------------------------------------------------------------
-- 计算人头数投票结果
---------------------------------------------------------------------------------
function GameMode:CalculateVoteResult(keys)
	-- local voteOption = keys.VoteOption
	-- local options = self.voteOptions
	-- local killsToWin = options['option' .. voteOption]
	-- self.TEAM_KILLS_TO_WIN = killsToWin
 	--    CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } );

 	local maxOption = 2 -- 默认选择第二个选项
	local maxVote = 0
	GameRules.VoteState = GameRules.VoteState or {{}, {}, {}}
	for k, votes in pairs(GameRules.VoteState) do
		local numVotes = table.count(votes)
		if numVotes > maxVote then
			maxVote = numVotes
			maxOption = k
		end
	end

	local killsToWin = self.voteOptions['option' .. maxOption]
	self.TEAM_KILLS_TO_WIN = killsToWin
    CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } );
end

---------------------------------------------------------------------------------
-- 人头数投票
---------------------------------------------------------------------------------
function GameMode:OnPlayerVote(keys)
	local option = keys.option
	local playerId = keys.PlayerID
	GameRules.VoteState = GameRules.VoteState or {{},{},{}}
	for k, votes in pairs(GameRules.VoteState) do
		if k ~= option then
			-- 从其他表中移除vote
			for s, pid in pairs(votes) do
				if pid == playerId then
					votes[s] = nil
				end
			end
		else
			if not table.contains(votes, playerId) then
				table.insert(votes, playerId)
			end
		end
	end

	CustomNetTables:SetTableValue('game_state', 'vote_state', GameRules.VoteState)

	self:CalculateVoteResult() -- 这个东西多运行几次没啥问题，会比较稳
end

---------------------------------------------------------------------------------
-- 同意洗牌
---------------------------------------------------------------------------------
function GameMode:OnPlayerAgreeToShuffle(keys)
	local playerId = keys.PlayerID
	GameRules.vAgreeToShufflePlayers = GameRules.vAgreeToShufflePlayers or {}
	if not table.contains(GameRules.vAgreeToShufflePlayers, playerId) then
		table.insert(GameRules.vAgreeToShufflePlayers, playerId)
	end

	CustomNetTables:SetTableValue("game_state", "agree_to_shuffle_players", GameRules.vAgreeToShufflePlayers)
end

---------------------------------------------------------------------------------
-- 同意开启狂野模式
---------------------------------------------------------------------------------
function GameMode:OnPlayerVoteForFreeMode(keys)
	local playerId = keys.PlayerID
	GameRules.vFreeModePlayers = GameRules.vFreeModePlayers or {}
	GameRules.vFreeModePlayers[playerId] = not GameRules.vFreeModePlayers[playerId]

	local t = {}
	for playerId, agree in pairs(GameRules.vFreeModePlayers) do
		if agree then
			table.insert(t, playerId)
		end
	end

	if table.count(t) >= 6 or 
		(IsInToolsMode() and table.count(t) >= 1)
		then
		GameRules.bFreeModeActivated = true
		print("free mode will be activated!")
	else
		print("free mode will NOT be activated!")
		GameRules.bFreeModeActivated = false
	end

	CustomNetTables:SetTableValue("game_state", "agree_to_free_mode_players", t)
end


---------------------------------------------------------------------------------
-- 请求星星数据
---------------------------------------------------------------------------------
function GameMode:OnClientAskForStar(keys)
	local playerId = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerId)
	if not player then return end
	local hero = player:GetAssignedHero()
	if not hero then return end
	if hero.UpdateStarToUI then
		hero:UpdateStarToUI()
	end

	if not hero.__bInited then
		self:InitPlayerHero(hero)
	end
end

---------------------------------------------------------------------------------
-- 重新随机英雄
---------------------------------------------------------------------------------
function GameMode:OnPlayerReRandomHero(keys)
	local playerId = keys.PlayerID
	if not GameRules.Plus:IsPlusPlayer(playerId) then return end
	GameRules.vReRandomState = GameRules.vReRandomState or {}
	if GameRules.vReRandomState[playerId] then return end
	GameRules.vReRandomState[playerId] = true
	local player = PlayerResource:GetPlayer(playerId)
	if not player then return end
	if player._bReRandomHero then return end
	player._bReRandomHero = true

	self:ShowRandomHeroSelection(playerId)
end

---------------------------------------------------------------------------------
-- 显示随机的英雄选择
---------------------------------------------------------------------------------
function GameMode:ShowRandomHeroSelection(i)

    local player = PlayerResource:GetPlayer(i)
    local hero = player:GetAssignedHero()

    local randomHero = table.random_some(GameRules.ValidHeroes, 3)
    while
        table.contains(randomHero, PlayerResource:GetSelectedHeroName(i)) 
        or ( table.contains(randomHero, "npc_dota_hero_gyrocopter")  and RollPercentage(90) )
        or ( table.contains(randomHero, "npc_dota_hero_silencer") and RollPercentage(80) )
        do
        randomHero = table.random_some(GameRules.ValidHeroes, 3)
    end

    hero._randomHero = randomHero

    Timer(0, function()
        if hero.__bReselectedHero__ or player.__bReselectedHero__ then
            CustomNetTables:SetTableValue('player_data', 'player_random_hero_selection_' .. i, {selected=true})
        else
            CustomGameEventManager:Send_ServerToPlayer(player,"player_random_hero_selection",hero._randomHero)
            CustomNetTables:SetTableValue('player_data', 'player_random_hero_selection_' .. i, hero._randomHero)
            return 1
        end
    end)
end