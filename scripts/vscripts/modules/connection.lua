if ConnectionManager == nil then 
	ConnectionManager = class({})
end

function ConnectionManager:constructor()
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(ConnectionManager, "OnGameRulesStateChange"), self)
	self.vPlayerHeroes = {}
end

function ConnectionManager:OnGameRulesStateChange()
end

function ConnectionManager:OnPlayerDisconnected(hero)
	self.vPlayerHeroes[hero] = false
	-- 如果说有多个玩家连接过，且现在只有一个玩家剩余，那么就结束游戏
	local connectedTeams = {}
	local lastTeam
	for hero, connected in pairs(self.vPlayerHeroes) do
		if connected then
			connectedTeams[hero:GetTeamNumber()] = true
			lastTeam = hero:GetTeamNumber()
		end
	end
	if table.count(self.vPlayerHeroes) > 1 and table.count(connectedTeams) <= 1 
		and GameRules.vHeroesForRating and table.count(GameRules.vHeroesForRating) >= 2 
		then
		GameRules:SetGameWinner(lastTeam)
	end
end

function ConnectionManager:OnPlayerHeroConnected(hero)
	self.vPlayerHeroes[hero] = true
end

function ConnectionManager:GetConnectTeamCount()
	local connectedTeams = {}
	for hero, connected in pairs(self.vPlayerHeroes) do
		if connected then
			connectedTeams[hero:GetTeamNumber()] = true
			lastTeam = hero:GetTeamNumber()
		end
	end
	return table.count(connectedTeams)
end

function ConnectionManager:GetLastPositionTeam()
	local lastPos = {}
	local anyTeamKills = false
	for hero, connected in pairs(self.vPlayerHeroes) do
		if connected then
			local team = hero:GetTeamNumber()
			local kills = GetTeamHeroKills(team)
			if kills > 0 then
				anyTeamKills = true
			end
			if lastPos.kills == nil or kills < lastPos.kills then
				lastPos.kills = kills
				lastPos.team = lastPos.team
			end
		end
	end
	if anyTeamKills then
		return lastPos.team
	end
	return nil
end

if GameRules.ConnectionManager == nil then 
	GameRules.ConnectionManager = ConnectionManager()
end