if Plus == nil then Plus = class({}) end

function Plus:constructor()
	CustomGameEventManager:RegisterListener('purchase_plus', function(_, keys)
		self:OnPlayerPurchasePlus(keys)
	end)

	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(Plus, "OnGameRulesStateChanged"), self)

	self.vPlusData = {}
end

function Plus:OnPlayerPurchasePlus(keys)
	local playerId = keys.PlayerID
	local steamid = PlayerResource:GetSteamAccountID(playerId)

	local req = CreateHTTPRequestScriptVM('POST', 'http://yueyutech.com:10011/PurchasePlus')
	req:SetHTTPRequestGetOrPostParameter('steamid', tostring(steamid))
	req:SetHTTPRequestGetOrPostParameter('days', tostring(keys.days))
	req:Send(function(result)
		if result.StatusCode == 200 then
			local body = result.Body
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), 'plus_purchase_result', {
				message = body
			})
		else
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), 'plus_purchase_result', {
				message = result.StatusCode
			})
		end
		self:QueryPlusDataFromServer()
	end)
end

function Plus:QueryPlusDataFromServer()
	local steamids = {}
	local steamid_playerid_map = {}
	for i = 0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayer(i) then
			local steamid = PlayerResource:GetSteamAccountID(i)
			table.insert(steamids, steamid)
			steamid_playerid_map[steamid] = playerid
		end
	end

	steamids = JSON:encode(steamids)

	local function queryPlusDataFromServer()
		local req = CreateHTTPRequestScriptVM('POST', 'http://yueyutech.com:10011/QueryPlusData')
		req:SetHTTPRequestGetOrPostParameter('steamid_json', steamids)

		req:Send(function(result)
			if result.StatusCode == 200 then
				local plus_data = JSON:decode(result.Body)
				for _,data in pairs(plus_data) do
					for i = 0, DOTA_MAX_TEAM_PLAYERS do
						if PlayerResource:GetSteamAccountID(i) == tonumber(data.steamid) then
							CustomNetTables:SetTableValue('econ_data', 'plus_data_' .. i, data)
							CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(i), 'plus_data_updated', {})
							if data.is_vip == true then
								self.vPlusData[i] = true
							end
						end
					end
				end
			else
				Timer(3, queryPlusDataFromServer)
			end
		end)
	end

	queryPlusDataFromServer()
end

function Plus:OnGameRulesStateChanged()
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		self:QueryPlusDataFromServer()
	end
end

function Plus:IsPlusPlayer(id)
	return self.vPlusData[id] == true
end

if GameRules.Plus == nil then GameRules.Plus = Plus() end