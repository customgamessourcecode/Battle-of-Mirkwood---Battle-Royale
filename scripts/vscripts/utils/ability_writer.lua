-- 用来写所有英雄的普通技能
if not IsInToolsMode() then return end

-- 读取所有英雄的数据
local heroes = LoadKeyValues('scripts/npc/activelist.txt')
local hero_data = LoadKeyValues('scripts/npc/npc_heroes.txt')

local hero_abilities = {}

for heroName in pairs(heroes) do
	local data = hero_data[heroName]
	for i = 1, 24 do
		local ability = data['Ability' .. i]
		if ability and not string.find(ability, 'special_bonus_') then
			table.insert(hero_abilities, ability)
		end
	end
end

local file = io.open('../../dota_addons/da/scripts/vscripts/data/all_hero_abilities', 'w')
file:write('return {\n')

for _, ability in pairs(hero_abilities) do
	local str = ',"' .. ability  .. '" = 100\n'
	file:write(str)
end

file:write('}')
file:flush()
file:close()
print("WRITING HERO ABILITIES COMPLETED")