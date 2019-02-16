local flLastCollectTime = -1
local flCollectInterval = 90

GameRules.DroppedItemPCFs = GameRules.DroppedItemPCFs or {}

function CheckDroppedItemPCFs()
	for _, d in pairs(GameRules.DroppedItemPCFs) do
		d.found = false
	end

	local items = Entities:FindAllByClassname("dota_item_drop")
	local now = GameRules:GetGameTime()
	for _, item in pairs(items) do
		if not item.itemDropPcf then
			if table.contains(GameRules.RandomDropAbilityScrolls, item:GetContainedItem():GetAbilityName()) then
				item.itemDropPcf = ParticleManager:CreateParticle('particles/items/'..item:GetContainedItem():GetAbilityName()..'.vpcf', PATTACH_ABSORIGIN, item)
				GameRules.DroppedItemPCFs[item:GetEntityIndex()] = {id = item.itemDropPcf, found = true}
			end
		else
			GameRules.DroppedItemPCFs[item:GetEntityIndex()].found = true
		end

		-- 收集掉落超过多长时间的道具
		if not item.dropTime then 
			item.dropTime = now
		elseif not item.removed then
			if now - item.dropTime > flCollectInterval then
				item.removed = true
				item:SetOrigin(Vector(9999,9999,0))
				UTIL_Remove(item)
			end
		end
	end

	for k, d in pairs(GameRules.DroppedItemPCFs) do
		if not d.found then
			ParticleManager:DestroyParticle(d.id, true)
			ParticleManager:ReleaseParticleIndex(d.id)
			GameRules.DroppedItemPCFs[k] = nil
		end
	end
end

Timer(function()
	if GameRules.nCountDownTimer and GameRules.nCountDownTimer < 12 * 60 then
		flCollectInterval = 30
	end
	CheckDroppedItemPCFs()
	return 0.1
end)