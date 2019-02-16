local INIT_MAX_STAR = 8
local STAR_SYSTEM_MAX_STAR = 15

if Star == nil then Star = class({}) end

local function getRandomStar(maxStar)
	local rt = {
		0.1, 0.35, 0.65, 0.9, 1.0
	}
	local rand = RandomFloat(0,1)
	local star = 0
	for i = 1, #rt do
		if (not rt[i-1] or (rt[i-1] < rand)) and (rand < rt[i]) then
			star = i
		end
	end
	return star -- 返回 4 3 2 1 0
end

local function getRandomBonus(starCount) -- 返回带有三位小数的属性增加值
	return math.round_off(math.normal_distribution(starCount / 2 - 0.1, 1.1, starCount / 2 - 1.8, starCount / 2 + 1.3), -3)
	-- return math.round_off(RandomFloat(starCount / 2 - 1.5, starCount / 2 + 1.3), -3)
end

function Star:Init(hero)
	hero.nRandomMaxStar = INIT_MAX_STAR
	hero.nCurrentStar = nil

	function hero:RandomCurrentStar()
		hero.nCurrentStar =  hero.nRandomMaxStar - getRandomStar(hero.nRandomMaxStar) + 1
		hero:RandomStarBonus()
	end

	function hero:RandomStarBonus()
		if not hero.nCurrentStar then
			hero:RandomCurrentStar()
		end
		hero.StarStrengthBonus = getRandomBonus(hero.nCurrentStar)
		hero.StarAgilityBonus = getRandomBonus(hero.nCurrentStar)
		hero.StarIntellectBonus = getRandomBonus(hero.nCurrentStar)
		hero:UpdateStarToUI()
	end

	function hero:UpdateStarToUI()
		if not PlayerResource:IsValidTeamPlayerID(hero:GetPlayerID()) then return end -- CCustomGameEventManager::ScriptSend_ServerToPlayer - Invalid player
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(hero:GetPlayerID()),
			"update_player_star", {
			nCurrentStar = hero.nCurrentStar,
			nMaxStar = hero.nRandomMaxStar,
			StarStrengthBonus = hero.StarStrengthBonus,
			StarAgilityBonus = hero.StarAgilityBonus,
			StarIntellectBonus = hero.StarIntellectBonus
		})

		-- for spectators
		GameRules.StarData = GameRules.StarData or {}
		GameRules.StarData[hero:entindex()] = {
			nCurrentStar = hero.nCurrentStar,
			nMaxStar = hero.nRandomMaxStar,
			StarStrengthBonus = hero.StarStrengthBonus,
			StarAgilityBonus = hero.StarAgilityBonus,
			StarIntellectBonus = hero.StarIntellectBonus,
		}
		CustomNetTables:SetTableValue("star_data","star_data", GameRules.StarData)
	end

	function hero:HasReachedMaxStar()
		return hero.nRandomMaxStar >= STAR_SYSTEM_MAX_STAR
	end

	function hero:AddStar()
		if not hero:HasReachedMaxStar() then
			hero.nRandomMaxStar = hero.nRandomMaxStar + 1
			hero:RandomCurrentStar()
			hero:UpdateStarToUI()
		else
			msg.bottom("#player_max_star", hero:GetPlayerID())
		end
	end

	function hero:RandomStar() -- 这里是商店购买的入口
		hero.shopRandomStarCount = hero.shopRandomStarCount or 0
		hero.shopRandomStarCount = hero.shopRandomStarCount + 1
		if hero.shopRandomStarCount >= hero.nRandomMaxStar - 5 then
			hero.shopRandomStarCount = nil
			if not hero:HasReachedMaxStar() then
				hero:AddStar()
			end
		end
		hero:RandomCurrentStar()
	end

	hero.nCurrentStar = 5
	hero.totalStrBonus = 0
	hero.totalAgiBonus = 0
	hero.totalIntBonus = 0
	hero:RandomStarBonus()
end



function Star:OnHeroLevelUp(keys)
	local player = EntIndexToHScript(keys.player)
	local hero = player:GetAssignedHero()
	local level = hero:GetLevel()
	if level == 17 or level == 19 or level == 21 or level == 22 or level == 23 or level == 24 then
		-- 现在英雄在这几个等级不给技能点数？
	else
		-- hero:SetAbilityPoints(hero:GetAbilityPoints() - 1) -- 降低英雄1点技能点数，移除升级带来的影响。
	end

	local function updateStarAttributes(h)
		h:SetBaseStrength(h:GetBaseStrength() + h.StarStrengthBonus)
		h:SetBaseAgility(h:GetBaseAgility() + h.StarAgilityBonus)
		h:SetBaseIntellect(h:GetBaseIntellect() + h.StarIntellectBonus)
		h:UpdateStarToUI()
	end

	if not hero:IsAlive() then
		hero:SetContextThink(DoUniqueString("wait_for_alive"), function()
			if hero:IsAlive() then
				updateStarAttributes(hero)
				return nil
			else
				return 1
			end
		end, 1)
	else
		updateStarAttributes(hero)
	end
end

function Star:constructor()
	ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap(self, "OnHeroLevelUp"), self)
end