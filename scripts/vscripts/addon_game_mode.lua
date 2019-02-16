-- Battle of Mirkwood - Battle Royale Game Mode
-- Created By Xavier @2017.4
--

print("Loading Dota Arena")

-------------------------------------------------------------------------------------------------------------
-- 初始化游戏模式
-------------------------------------------------------------------------------------------------------------


if _G.GameMode == nil then
	_G.GameMode = class({})
end

-------------------------------------------------------------------------------------------------------------
-- 类似于python中的文件载入机制
-- 使用一个文件夹中的_loader载入文件夹中的所有需要载入的文件
-- 这个函数当然会同时运行_loader中的所有语句
-- path表示文件夹
-------------------------------------------------------------------------------------------------------------
function xrequire(path)
	local files = require(path .. '._loader')
	if not files then
		error('xrequire Failed to load' .. path)
	end

	if files and type(files) == 'table' then
		for _, file in pairs(files) do
			require(path .. '.' .. file)
		end
	elseif files and not type(files) == 'table' then
		print(path, 'doesnt return a table contains files to require, ignoring!!!!')
	end
end

xrequire 'utils'
xrequire 'modifiers'
xrequire 'modules'

Precache = require "Precache" -- 预载入在这里！！！

require "Debug"
require "UI"
require "GameMode"
require 'libraries/notifications'


function Activate()
	GameRules.GameMode = GameMode()
	GameRules.GameMode:InitGameMode()
end


local _print = print
function print(...)
	if IsInToolsMode() then
		_print(...)
	end
end

-------------------------------------------------------------------------------------------------------------
-- 以下内容没有写在函数里面，是为了在测试的时候每次reload都可以重新载入技能、单位的数据
-- 现在已经不需要写在外面了，但是懒得挪了
-- 就这样吧，目前不会有什么错误
-- 
-------------------------------------------------------------------------------------------------------------
-- 载入KV数据
-------------------------------------------------------------------------------------------------------------
GameRules.Heroes_KV = LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
GameRules.Items_KV = LoadKeyValues('scripts/npc/npc_items_custom.txt')
GameRules.Units_KV = LoadKeyValues('scripts/npc/npc_units_custom.txt')
GameRules.Abilities_KV = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')
GameRules.DotaItems_KV = LoadKeyValues("scripts/npc/items.txt")
GameRules.OverrideAbility_KV = LoadKeyValues("scripts/npc/npc_abilities_override.txt")
GameRules.OriginalAbilities = LoadKeyValues("scripts/npc/npc_abilities.txt")
GameRules.OriginalHeroes = LoadKeyValues("scripts/npc/npc_heroes.txt")
-- 去除几个无效的字段
GameRules.OriginalHeroes['Version'] = nil
GameRules.OriginalHeroes['npc_dota_hero_target_dummy'] = nil

GameRules.ValidHeroes = LoadKeyValues("scripts/npc/herolist.txt")
-------------------------------------------------------------------------------------------------------------
-- 处理一下英雄的KV，以英雄本身的名字作为index
-------------------------------------------------------------------------------------------------------------
for _, data in pairs(GameRules.Heroes_KV) do
    if data and type(data) == "table" then
        GameRules.Heroes_KV[data.override_hero] = data
    end
end
-------------------------------------------------------------------------------------------------------------
-- 处理一下英雄的名字
-------------------------------------------------------------------------------------------------------------
for index, valid in pairs(GameRules.ValidHeroes) do
	if tonumber(valid) ~= 1 then
		GameRules.ValidHeroes[index] = nil
	end
end
GameRules.ValidHeroes = table.make_key_table(GameRules.ValidHeroes) -- 做一个key的表
-------------------------------------------------------------------------------------------------------------
-- 处理技能数据，做出几个表给游戏模式用
-------------------------------------------------------------------------------------------------------------
if GameRules.AvailableHeroesThisGame == nil then -- 重载的时候不重载技能
	local heroNameThisGame = table.random_some(table.make_key_table(GameRules.OriginalHeroes), 50)
	GameRules.AvailableHeroesThisGame = {}
	for _, heroName in pairs(heroNameThisGame) do
		GameRules.AvailableHeroesThisGame[heroName] = GameRules.OriginalHeroes[heroName]
	end
	GameRules.vBlackList = require("data/black_list")
	GameRules.vNormalAbilitiesPool = {}
	GameRules.vUltimateAbilitiesPool = {}

	GameRules.vHeroAbilityPoolForPlus = {}

	for heroName, data in pairs(GameRules.AvailableHeroesThisGame) do
		if type(data) == "table" then

			local hero_abilities = {}

			for i = 1, 23 do
				local abilityName = data["Ability" .. i]
				if abilityName then
					if GameRules.OriginalAbilities[abilityName] and
						GameRules.OriginalAbilities[abilityName].AbilityType ~= "DOTA_ABILITY_TYPE_ATTRIBUTES" and
						not table.contains(GameRules.vBlackList, abilityName) 
						then

						table.insert(hero_abilities, abilityName)

						-- 根据技能类型的不同，分别放到各自的表中
						if GameRules.OriginalAbilities[abilityName].AbilityType ~= "DOTA_ABILITY_TYPE_ULTIMATE" then
							table.insert(GameRules.vNormalAbilitiesPool, abilityName)
						else
							table.insert(GameRules.vUltimateAbilitiesPool, abilityName)
						end
					end
				end
			end

			table.insert(GameRules.vHeroAbilityPoolForPlus, {hero = heroName, abilities = hero_abilities})
		end
	end
end

-- 将来自其他游戏的技能放到技能池里面去
-- todo，不知道啥时候开始做的feature

if not IsInToolsMode() then return end