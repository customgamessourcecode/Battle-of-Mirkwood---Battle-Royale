local particles = {
    "particles/treasure_courier_death.vpcf",
    "particles/leader/leader_overhead.vpcf",
    "particles/generic_gameplay/screen_damage_indicator.vpcf",
    "particles/econ/items/viper/viper_ti7_immortal/viper_poison_crimson_debuff_ti7.vpcf",
    "particles/status_fx/status_effect_poison_viper.vpcf",
    "particles/generic_gameplay/screen_poison_indicator.vpcf",
    "particles/core/border.vpcf",
}

local sounds = {

}

local function PrecacheEverythingFromTable( context, kvtable)
    for key, value in pairs(kvtable) do
        if type(value) == "table" then
            PrecacheEverythingFromTable( context, value )
        else
            if string.find(value, "vpcf") then
                PrecacheResource( "particle", value, context)
            end
            if string.find(value, "vmdl") then
                PrecacheResource( "model", value, context)
            end
            if string.find(value, "vsndevts") then
                PrecacheResource( "soundfile", value, context)
            end
        end
    end
end

function PrecacheEverythingFromKV( context )
    local kv_files = {
        "scripts/npc/npc_units_custom.txt",
        "scripts/npc/npc_abilities_custom.txt",
        "scripts/npc/npc_heroes_custom.txt",
        "scripts/npc/npc_abilities_override.txt",
        "scripts/npc/npc_items_custom.txt",
    }
    for _, kv in pairs(kv_files) do
        local kvs = LoadKeyValues(kv)
        if kvs then
            -- print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
            PrecacheEverythingFromTable( context, kvs)
        end
    end
end

return function(context)
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
    PrecacheEverythingFromKV(context)
    
    for _, p in pairs(particles) do
        PrecacheResource("particle", p, context)
    end
    for _, p in pairs(sounds) do
        PrecacheResource("soundfile", p, context)
    end

	for unit in pairs(LoadKeyValues("scripts/npc/npc_units_custom.txt")) do
        PrecacheUnitByNameSync(unit,context,0)
    end

    -- 预载入所有要用到的英雄
    -- if not IsInToolsMode() then -- 在测试的时候不预载入，加快测试速度
        for heroName, _ in pairs(GameRules.AvailableHeroesThisGame) do
            PrecacheUnitByNameSync(heroName, context, -1)
            -- PrecacheUnitByNameAsync(heroName,function()
            --     GameRules.vHeroPrecached = GameRules.vHeroPrecached or {}
            --     GameRules.vHeroPrecached[heroName] = true
            --     print(heroName, "precache finished")
            -- end,-1)
        end
    -- end

    PrecacheItemByNameSync( "item_treasure_chest", context )
    PrecacheModel( "item_treasure_chest", context )
end