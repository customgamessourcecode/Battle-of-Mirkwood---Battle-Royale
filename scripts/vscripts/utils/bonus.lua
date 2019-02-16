utilsBonus = {}

local auto_use_items = {
    "item_coin",
}

-- 掉落物品
function utilsBonus.DropLootItem(itemname, position, radius)
    --print("creating item ", itemname)
    local newItem = CreateItem(itemname, nil, nil)

    if not newItem then 
        print("ERROR: FAILED TO CREATE ITEM!!!!!")
        return 
    end

    newItem:SetPurchaseTime(0)
    radius = radius or 0
    local drop       = CreateItemOnPositionSync(position, newItem)
    local dropTarget = position + RandomVector(RandomFloat(0, radius))

    local maxTries = 0
    while not GridNav:CanFindPath(position, dropTarget) do
        dropTarget = position + RandomVector(RandomFloat(0, radius))
        maxTries = maxTries + 1
        if maxTries > 10 then break end
    end
    local autouse    = false

    -- 各种自动拾取的东西（就是不需要选择，都可以捡起来的，不会有任何坏处的）
    if table.contains(auto_use_items, itemname) then
        autouse = true
    end

    local height, time = 300, 0.75
    newItem:LaunchLoot(autouse, height, time, dropTarget)

    -- 显示特效
    if not drop.itemDropPcf then
        if table.contains(GameRules.RandomDropAbilityScrolls, itemname) then
            drop.itemDropPcf = ParticleManager:CreateParticle('particles/items/'..itemname..'.vpcf', PATTACH_ABSORIGIN, drop)
            GameRules.DroppedItemPCFs[drop:GetEntityIndex()] = {id = drop.itemDropPcf, found = true}
        end
        if itemname == "item_spellbook_normal"
            or itemname == "item_spellbook_normal_courier" 
            or itemname == "item_spellbook_ultimate" 
            or itemname == "item_spellbook_ultimate_courier" 
            then
            local pcf = ParticleManager:CreateParticle('particles/items/spellbook_drop.vpcf', PATTACH_WORLDORIGIN, drop)
            ParticleManager:SetParticleControl(pcf, 0, position)
            ParticleManager:ReleaseParticleIndex(pcf)
        end
    end

    return newItem, drop
end