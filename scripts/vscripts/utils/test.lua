center = {-183, -334}
p1 = {-3780, -1764}
p2 = {-5794, -1882}
function legnth(d1, d2)
	local dx = d1[1] - d2[1]
	local dy = d1[2] - d2[2]
	return math.sqrt(dx * dx + dy * dy)
end

print(legnth(center, p1))
print(legnth(center, p2))