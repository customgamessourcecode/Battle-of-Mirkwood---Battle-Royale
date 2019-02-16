-- 用来写所有可以通行的地点，如果有地形更新之后，需要更新这个data
if not IsInToolsMode() then return end

local center = Entities:FindByName(nil, "world_center"):GetOrigin()
local file = io.open('../../dota_addons/da/scripts/vscripts/data/grid_positions.lua', 'w')
file:write('return {\n {x=0, y=0}\n')

for x = GetWorldMinX(), GetWorldMaxX(), 128 do
	for y = GetWorldMinY(), GetWorldMaxY(), 128 do
		if GridNav:CanFindPath(center, Vector(math.floor(x), math.floor(y), 256)) then
			local str = ',{x=' .. math.floor(x) .. ',y=' ..math.floor(y) .. '}\n'
			file:write(str)
		end
	end
end

file:write('}')
file:flush()
file:close()
print("GRID POSITIONS UPDATE COMPLETE!")