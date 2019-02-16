-- 用来将天赋数据写到panorama的js中去
if not IsInToolsMode() then return end
-- do return end -- 暫時不要重複寫

-- 读取所有英雄的数据
local heroes = LoadKeyValues('scripts/npc/herolist.txt')
local hero_data = LoadKeyValues('scripts/npc/npc_heroes.txt')

local hero_talent_data = {}

local hero_attribute_data = {}

for heroName in pairs(heroes) do
	local data = hero_data[heroName]

	local talents = {}
	for i = 1, 24 do
		local ability = data['Ability' .. i]
		if ability and string.find(ability, 'special_bonus_') then
			table.insert(talents, ability)
		end
	end

	table.insert(hero_talent_data, {hero = heroName, talents = talents})

	table.insert(hero_attribute_data, {hero = heroName, attribute = data.AttributePrimary})
end

local file = io.open('../../../content/dota_addons/da/panorama/scripts/custom_game/talents.js', 'w')
file:write('GameUI.vTalentData = {\n')

for _, data in pairs(hero_talent_data) do
	local str = '"' .. data.hero .. '":{'
	for index, talent in pairs(data.talents) do
		str = str .. index ..  ':"' .. talent .. '",'
	end
	-- str = string.sub(str, 1, string.len(str) - 1)
	str = str .. '},\n'
	file:write(str)
end

file:write('}')
file:flush()
file:close()

local file = io.open('../../../content/dota_addons/da/panorama/scripts/custom_game/attributes.js', 'w')
file:write('GameUI.vAttributeData = {\n')

for _, data in pairs(hero_attribute_data) do
	local str = '"' .. data.hero .. '":'
	-- str = string.sub(str, 1, string.len(str) - 1)
	str = str .. '"'.. data.attribute .. '",\n'
	file:write(str)
end

file:write('}')
file:flush()
file:close()