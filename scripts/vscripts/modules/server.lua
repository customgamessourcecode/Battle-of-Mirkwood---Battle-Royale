GameRules.__NewAuthKey__ = 'V*T*)GO!V(&@TGEBF*&T!*%@*(&FGV$$O!)^*&@TY#UGB!TGRF@)*#(!U'
GameRules.__NewServerUrl__ = "http://yueyutech.com:10011"

if Server == nil then Server = class({}) end

local function stringTable(t)
    local s = {}
    for k,v in pairs(t) do
        if type(v) == 'table' then
            s[k] = stringTable(v)
        else s[k] = tostring(v)
        end
    end
    return s
end

local function CreateHTTPRequestScriptVMWithKey(method, url)
    local req = CreateHTTPRequestScriptVM(method,url)
    req:SetHTTPRequestGetOrPostParameter('auth', GameRules.__NewAuthKey__)
    return req
end

function Server:constructor()
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(Server, "OnGameStateChanged"), nil)
    CustomGameEventManager:RegisterListener("QueryPlayerRating", Dynamic_Wrap(Server, "OnQueryPlayerRating"))
    CustomGameEventManager:RegisterListener("GetLadder", Dynamic_Wrap(Server, "OnGetTop50"))
end

function Server:OnGetTop50()
    local request_str = GameRules.__NewServerUrl__ .. "/GetTop50"
    local req = CreateHTTPRequestScriptVM("POST", request_str)
    req:Send(function(result)
        if result.StatusCode == 200 then
            local body = JSON:decode(result.Body)
            if body ~= nil then
                CustomNetTables:SetTableValue("top_50", "top_50", stringTable(body))
            end
        end
    end)
end

function Server:OnQueryPlayerRating()
    local players = {}

    local steamid_playerid_map = {}

    for id = 0, DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayer(id) then
            local steamid = PlayerResource:GetSteamAccountID(id)
            steamid_playerid_map[steamid] = id
            table.insert(players, steamid)
        end
    end
    local player_json = JSON:encode(players)
    local req = CreateHTTPRequestScriptVM("POST", GameRules.__NewServerUrl__ .. "/GetRating")
    req:SetHTTPRequestGetOrPostParameter('player_json', player_json)
    req:SetHTTPRequestGetOrPostParameter('mapname', GetMapName())
    req:Send(function(result)
        if result.StatusCode == 200 then
            local body = JSON:decode(result.Body)

            -- 记录数据
            GameRules.vDCTData = GameRules.vDCTData or {}
            for _, data in pairs(body) do
                if data['dct'] then
                    local id = steamid_playerid_map[data['steamid']]
                    GameRules.vDCTData[id] = data['dct']
                end
            end

            CustomNetTables:SetTableValue("player_rating_data", "rating_data", stringTable(body));
            CustomGameEventManager:Send_ServerToAllClients('player_rating_data_arrived', {})
        end
    end)

    -- 发送请求去获取玩家的数据统计
    local req = CreateHTTPRequestScriptVM("POST", GameRules.__NewServerUrl__ .. "/GetStastics")
    req:SetHTTPRequestGetOrPostParameter('player_json', player_json)
    req:Send(function(result)
        if result.StatusCode == 200 then
            local body = JSON:decode(result.Body)
            CustomNetTables:SetTableValue("player_rating_data", "stastics_data", stringTable(body));
            CustomGameEventManager:Send_ServerToAllClients('player_stastics_data_arrived', {})
        end
    end)
end

function Server:OnGameStateChanged(something, debug)
    local newState = GameRules:State_Get()
    if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        Server:OnQueryPlayerRating()
        Server:OnGetTop50()
    end
    if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        local req = CreateHTTPRequestScriptVMWithKey( "POST", GameRules.__NewServerUrl__ .. "/NewMatch")
        local players = {}
        for id = 0, DOTA_MAX_TEAM_PLAYERS do
            local player = PlayerResource:GetPlayer(id)
            if PlayerResource:IsValidTeamPlayer(id) then
                table.insert(players, PlayerResource:GetSteamAccountID(id))
            end
        end
        req:SetHTTPRequestGetOrPostParameter('player_json',JSON:encode(players))
        req:SetHTTPRequestGetOrPostParameter('mapname',GetMapName())
        req:Send(function(result)
            if result.StatusCode == 200 then
                GameRules.__RatingGameID__ = result.Body
                Notifications:Bottom(player, { text = 'hud_tooltip_rating_and_disconnect', duration = 15, style = { color = "red", ["font-size"] = "30px", border = "0px" } , continue = continue})
            end
        end)
    end

    if newState >= DOTA_GAMERULES_STATE_POST_GAME and (GameRules.__RatingGameID__ or IsInToolsMode() )then
        local sortedTeams = {}
        local teams = {2,3,6,7,8,9,10,11,12,13}
        for i = 1, GameRules.GameMode.nTeamCount do
            table.insert(sortedTeams, {
                teamID = teams[i],
                teamScore = GetTeamHeroKills( teams[i] )
            })
        end

        -- reverse-sort by score
        table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

        local sortedPlayers = {}
        for _, team in pairs(sortedTeams) do
            local playerInTeam = {}
            for hero in pairs(GameRules.vHeroesForRating) do
                local t = hero:GetTeamNumber()
                if t == team.teamID then
                    local steamid = PlayerResource:GetSteamAccountID(hero:GetPlayerID())
                    if steamid ~= 0 then -- 换过英雄的，会有一个假的，为0的英雄一直存在于这个游戏
                        local data = {
                            steamid=steamid, 
                            k=hero:GetKills(),
                            d=hero:GetDeaths(),
                            a=hero:GetAssists()
                        }
                        if hero.flDisconnectStartTime then
                            local dct = GameRules:GetGameTime() - hero.flDisconnectStartTime
                            data.dct = math.floor(dct)
                        end
                        table.insert(playerInTeam, data)
                    end
                end
            end
            if #playerInTeam > 0 then
                table.insert(sortedPlayers, playerInTeam)
            end
        end

        Timer(1,function()
            local req = CreateHTTPRequestScriptVMWithKey( "POST", GameRules.__NewServerUrl__ .. "/EndMatch")
            req:SetHTTPRequestGetOrPostParameter('gameid',tostring(GameRules.__RatingGameID__))
            req:SetHTTPRequestGetOrPostParameter('mapname',GetMapName())
            req:SetHTTPRequestGetOrPostParameter('match_result',JSON:encode(sortedPlayers))
            req:Send(function(result)
               if result.StatusCode == 200 then
                    rating_data = JSON:decode(result.Body)
                    CustomNetTables:SetTableValue('end_game_rating',"end_game_rating",stringTable(rating_data))
                    CustomGameEventManager:Send_ServerToAllClients('endrating_arrived', {})
               end
            end)
        end)

        local hero_ability_stats = {}
        for hero in pairs(GameRules.vHeroesForRating) do
            local ability = {}
            for i = 0, 23 do
                local a = hero:GetAbilityByIndex(i)
                if a and not string.find(a:GetAbilityName(), "special_bonus_") then
                    table.insert(ability, {n = a:GetAbilityName(), l = a:GetLevel()})
                end
            end
            table.insert(ability, {n = hero:GetUnitName(), l = 1})
            table.insert(hero_ability_stats, ability)
        end

        local req1 = CreateHTTPRequestScriptVM('POST', GameRules.__NewServerUrl__ .. '/SaveAbilityStats')
        req1:SetHTTPRequestGetOrPostParameter('abilities', JSON:encode(hero_ability_stats))
        req1:Send(function(result)
        end)
    end
end

if GameRules.Server == nil then GameRules.Server = Server() end
