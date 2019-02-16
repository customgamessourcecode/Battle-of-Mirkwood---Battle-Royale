if Treasure == nil then Treasure = class({}) end

local INITIAL_TRASURE_SPAWN_TIME = 600
local TREASURE_SPAWN_INTERVAL = 120

function Treasure:OnPlayerPickupItem( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	local hero = owner:GetClassname()
	local ownerTeam = owner:GetTeamNumber()
	local sortedTeams = {}
	local teams = {2,3,6,7,8,9,10,11,12,13}
	for i = 1, GameRules.GameMode.nTeamCount do
		table.insert(sortedTeams, {
			teamID = teams[i],
			teamScore = GetTeamHeroKills(teams[i]),	
		})
	end
	-- reverse-sort by score
	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )
	local n = table.count(sortedTeams)
	local leader = sortedTeams[1].teamID
	local lastPlace = sortedTeams[n].teamID

	local tableindex = 0
	local tier1 = 
	{
		"item_urn_of_shadows",
		"item_ring_of_basilius",
		"item_ring_of_aquila",
		"item_arcane_boots",
		"item_tranquil_boots",
		"item_phase_boots",
		"item_power_treads",
		"item_medallion_of_courage",
		"item_soul_ring",
		"item_gem",
		"item_orb_of_venom"
	}
	local tier2 = 
	{
		"item_blink",
		"item_force_staff",
		"item_cyclone",
		"item_ghost",
		"item_vanguard",
		"item_mask_of_madness",
		"item_blade_mail",
		"item_helm_of_the_dominator",
		"item_vladmir",
		"item_yasha",
		"item_mekansm",
		"item_hood_of_defiance",
		"item_veil_of_discord",
		"item_glimmer_cape"
	}
	local tier3 = 
	{
		"item_shivas_guard",
		"item_sphere",
		"item_diffusal_blade",
		"item_maelstrom",
		"item_basher",
		"item_invis_sword",
		"item_desolator",
		"item_ultimate_scepter",
		"item_bfury",
		"item_pipe",
		"item_heavens_halberd",
		"item_crimson_guard",
		"item_black_king_bar",
		"item_bloodstone",
		"item_lotus_orb",
		"item_guardian_greaves",
		"item_moon_shard"
	}
	local tier4 = 
	{
		"item_skadi",
		"item_sange_and_yasha",
		"item_greater_crit",
		"item_sheepstick",
		"item_orchid",
		"item_heart",
		"item_mjollnir",
		"item_ethereal_blade",
		"item_radiance",
		"item_abyssal_blade",
		"item_butterfly",
		"item_monkey_king_bar",
		"item_satanic",
		"item_octarine_core",
		"item_silver_edge",
		"item_rapier"
	}

	local t1 = table.random(tier1)
	local t2 = table.random(tier2)
	local t3 = table.random(tier3)
	local t4 = table.random(tier4)

	local spawnedItem = ""

	-- pick the item we're giving them

	-- 各个排名的都有概率获得空箱子，但是不要那么明显
	-- 第一名 70%概率空箱子
	if (ownerTeam == sortedTeams[1].teamID and RollPercentage(70))
		or (ownerTeam == sortedTeams[2].teamID and RollPercentage(20))
		then
		CustomGameEventManager:Send_ServerToAllClients( "leader_got_nothing", {} )
		return
	end

	if GetTeamHeroKills( leader ) > 5 and GetTeamHeroKills( leader ) <= 10 then
		if ownerTeam == leader and ( self.leadingTeamScore - self.runnerupTeamScore > 3 ) then
			spawnedItem = t1
		elseif ownerTeam == lastPlace then
			spawnedItem = t3
		else
			spawnedItem = t2
		end
	elseif GetTeamHeroKills( leader ) > 10 and GetTeamHeroKills( leader ) <= 15 then
		if ownerTeam == leader and ( self.leadingTeamScore - self.runnerupTeamScore > 3 ) then
			spawnedItem = t2
		elseif ownerTeam == lastPlace then
			spawnedItem = t4
		else
			spawnedItem = t3
		end
	else
		spawnedItem = t2
	end

	-- add the item to the inventory and broadcast
	owner:AddItemByName( spawnedItem )
	EmitGlobalSound("powerup_04")
	local overthrow_item_drop =
	{
		hero_id = hero,
		dropped_item = spawnedItem
	}
	CustomGameEventManager:Send_ServerToAllClients( "overthrow_item_drop", overthrow_item_drop )
end

function Treasure:WarnItem()
	local pos = GameRules.GameMode:GetRandomValidPosition()
	self.itemSpawnLocation = pos
	local spawnLocation = self.itemSpawnLocation
	CustomGameEventManager:Send_ServerToAllClients( "item_will_spawn", {} )
	EmitGlobalSound( "powerup_03" )

	self.fakeItemSpawnLocation = {}

	local fakePosition = GameRules.GameMode:GetRandomValidPosition()

	local maxTries = 10
	while (fakePosition - pos):Length2D() < 4000 and maxTries > 0 do
		fakePosition = GameRules.GameMode:GetRandomValidPosition()
		maxTries = maxTries - 1
	end
	table.insert(self.fakeItemSpawnLocation, fakePosition)

	CustomGameEventManager:Send_ServerToAllClients( "item_will_spawn", table.join(self.fakeItemSpawnLocation, {self.itemSpawnLocation}) )
end

function Treasure:_SpawnItem(targetLocation, real)
	CustomGameEventManager:Send_ServerToAllClients( "item_has_spawned", {} )
	EmitGlobalSound( "powerup_05" )

	local minx, miny, maxx, maxy = GetWorldMinX(), GetWorldMinY(), GetWorldMaxX(), GetWorldMaxY()
	local spawnPos = Vector(minx, miny, 0)
	if (targetLocation.x > 0 and targetLocation.y > 0) then
	elseif targetLocation.x > 0 and targetLocation.y < 0 then
		spawnPos = Vector(minx, maxy, 0)
	elseif targetLocation.x < 0 and targetLocation.y > 0 then
		spawnPos = Vector(maxx, miny, 0)
	elseif targetLocation.x < 0 and targetLocation.y < 0 then
		spawnPos = Vector(maxx, maxy, 0)
	end

	local treasureCourier = CreateUnitByName( "npc_dota_treasure_courier" , spawnPos, true, nil, nil, DOTA_TEAM_NEUTRALS )

	if real then treasureCourier.real = true end

	local treasureAbility = treasureCourier:FindAbilityByName( "dota_ability_treasure_courier" )
	treasureAbility:SetLevel( 1 )
    local goalEntity = SpawnEntityFromTableSynchronous("info_target",{
        origin = targetLocation,
    })
    local teams = {2,3,6,7,8,9,10,11,12,13}
    treasureCourier.fowViewers = {}
    for _, team in pairs(teams) do
    	table.insert(treasureCourier.fowViewers,CreateUnitByName("npc_vision_revealer",targetLocation,false,nil,nil,team))
    end
    for _, team in pairs(teams) do
    	local unit = CreateUnitByName("npc_vision_revealer",spawnPos,false,nil,nil,team)
    	Timer(0.03, function()
    		if IsValidAlive(treasureCourier) then
    			unit:SetOrigin(treasureCourier:GetOrigin())
    			return 0.03
    		else
    			UTIL_Remove( unit )
    			return nil
    		end
    	end)
    end
    treasureCourier:SetInitialGoalEntity(goalEntity)

    local particleTreasure = ParticleManager:CreateParticle( "particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_ABSORIGIN, treasureCourier )
	ParticleManager:SetParticleControlEnt( particleTreasure, PATTACH_ABSORIGIN, treasureCourier, PATTACH_ABSORIGIN, "attach_origin", treasureCourier:GetAbsOrigin(), true )
	treasureCourier:Attribute_SetIntValue( "particleID", particleTreasure )

	Timer(function()
		local to = treasureCourier:GetOrigin()
		local o = goalEntity:GetOrigin()
		if (to - o):Length2D() < 5000 then
			self:ShowHintAtLocation(to)
			return nil
		else
			return 1
		end
	end)
end

function Treasure:ShowHintAtLocation(pos)
	for i = 0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:GetPlayer(i) and PlayerResource:GetPlayer(i):GetAssignedHero() then
			ent = PlayerResource:GetPlayer(i):GetAssignedHero()
		end
	end
	for _, team in pairs(GameRules.vTeamsInGame) do
		MinimapEvent(team, ent, pos.x, pos.y, DOTA_MINIMAP_EVENT_HINT_LOCATION , 3)
	end
end

function Treasure:ForceSpawnItem()
	self:WarnItem()
	self:SpawnItem()
end

function Treasure:TreasureDrop( treasureCourier )
	--Create the death effect for the courier
	local spawnPoint = treasureCourier:GetInitialGoalEntity():GetAbsOrigin()
	spawnPoint.z = 400
	local fxPoint = treasureCourier:GetInitialGoalEntity():GetAbsOrigin()
	fxPoint.z = 400
	local deathEffects = ParticleManager:CreateParticle( "particles/treasure_courier_death.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( deathEffects, 0, fxPoint )
	ParticleManager:SetParticleControlOrientation( deathEffects, 0, treasureCourier:GetForwardVector(), treasureCourier:GetRightVector(), treasureCourier:GetUpVector() )
	EmitGlobalSound( "lockjaw_Courier.Impact" )
	EmitGlobalSound( "lockjaw_Courier.gold_big" )

	local fowViewers = treasureCourier.fowViewers
	Timer(10, function()
		for _, v in pairs(fowViewers) do
			UTIL_Remove( v )
		end
	end)

	local real = treasureCourier.real
	local rightVector = treasureCourier:GetRightVector()
	UTIL_Remove( treasureCourier )

	if real ~= true then 
		return 
	end -- 如果不是真实的，那么就不投放东西

	--Spawn the treasure chest at the selected item spawn location
	local newItem = CreateItem( "item_treasure_chest", nil, nil )
	local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
	drop:SetForwardVector(rightVector) -- oriented differently
	newItem:LaunchLootInitialHeight( false, 0, 50, 0.25, spawnPoint )

	-- destroy trees
	GridNav:DestroyTreesAroundPoint(spawnPoint,500,true)

	local function DropLootAbilityScroll(itemName)
		local newItem = CreateItem(itemName, nil, nil)
		newItem:SetPurchaseTime(0)
		local drop = CreateItemOnPositionSync(spawnPoint, newItem)
		drop:SetRenderColor(255, 0, 0)
		
		local dropTarget = spawnPoint + RandomVector(RandomFloat(350, 450))
		while not GridNav:CanFindPath(dropTarget, spawnPoint) do
			dropTarget = spawnPoint + RandomVector(RandomFloat(350, 450))
		end

		newItem:LaunchLoot(false, 300, 0.75, dropTarget)

	end
	-- 在附近掉1-2张普通技能卷轴和有概率的1张终极技能卷轴
	local normalAbilityCount = RandomInt(1,3)
	if RollPercentage(70) then
		DropLootAbilityScroll("item_spellbook_normal_courier")
		if RollPercentage(30) then
			DropLootAbilityScroll("item_spellbook_normal_courier")
		end
	end
	if RollPercentage(10) then
		DropLootAbilityScroll("item_spellbook_ultimate_courier")
	end
end

function Treasure:SpawnItem()
	self:_SpawnItem(self.itemSpawnLocation, true)
	for _, loc in pairs(self.fakeItemSpawnLocation) do
		self:_SpawnItem(loc, false)
	end
end

function Treasure:ThinkSpecialItemDrop()

	local now = GameRules:GetDOTATime(false,false)
	if self.flLastItemDropTime == nil then
		self.flLastItemDropTime = now + INITIAL_TRASURE_SPAWN_TIME
	end
	if now - self.flLastItemDropTime > TREASURE_SPAWN_INTERVAL then
		self:WarnItem()
		self.flLastItemDropTime = now
		Timer(5, function()
			self:SpawnItem()
		end)
	end
end

function Treasure:constructor()
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(Treasure, "OnGameRulesStateChange"), self)
	ListenToGameEvent( "dota_npc_goal_reached", Dynamic_Wrap( Treasure, "OnNpcGoalReached" ), self )
	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( Treasure, "OnItemPickUp" ), self )
end

function Treasure:OnGameRulesStateChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		Timer(1, function()
			if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS 
				and GameRules.nCountDownTimer > 200
				then
				self:ThinkSpecialItemDrop()
			end
			return 1
		end)
	end
end

function Treasure:OnNpcGoalReached( event )
	local npc = EntIndexToHScript( event.npc_entindex )
	if npc:GetUnitName() == "npc_dota_treasure_courier" then
		local pos = npc:GetOrigin()
		self:ShowHintAtLocation(pos)		
		Timer(RandomFloat(3,6), function()
			self:TreasureDrop( npc )
		end)
	end
end

function Treasure:OnItemPickUp( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	if event.itemname == "item_treasure_chest" then
		self:OnPlayerPickupItem( event )
		UTIL_Remove( item )
	end
end


if GameRules.Treasure == nil then GameRules.Treasure = Treasure() end