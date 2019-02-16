function EconRemoveParticle(pid)
	ParticleManager:DestroyParticle(pid, true)
	ParticleManager:ReleaseParticleIndex(pid)
end

function EconCreateParticleOnHero(hero, particleName)
	local pid = ParticleManager:CreateParticle(particleName,PATTACH_ABSORIGIN_FOLLOW,hero)
	ParticleManager:SetParticleControlEnt(pid,0,hero,PATTACH_ABSORIGIN_FOLLOW,"follow_origin",hero:GetAbsOrigin(),true)
	return pid
end

function EconCreateParticleOverhead(hero, particleName)
	local pid = ParticleManager:CreateParticle(particleName,PATTACH_OVERHEAD_FOLLOW,hero)
	ParticleManager:SetParticleControlEnt(pid,0,hero,PATTACH_OVERHEAD_FOLLOW,"follow_overhead",hero:GetAbsOrigin(),true)
	return pid
end

Econ = {}

-----------------------------------------------------------------------------------------------------------------------
-- 虚无之焰 白色
Econ.OnEquip_ethereal_flame_white_server = function(hero)
	if hero.nParticleEtherealFlameWhite then
		EconRemoveParticle(hero.nParticleEtherealFlameWhite)
	end
	hero.nParticleEtherealFlameWhite = EconCreateParticleOnHero(hero, "particles/econ/ethereal_flame.vpcf")
	ParticleManager:SetParticleControl(hero.nParticleEtherealFlameWhite, 15, Vector(200, 200, 200))
	ParticleManager:SetParticleControl(hero.nParticleEtherealFlameWhite, 2, Vector(255, 255, 255))
	ParticleManager:SetParticleControl(hero.nParticleEtherealFlameWhite, 16, Vector(1, 0, 0))
end

Econ.OnRemove_ethereal_flame_white_server = function(hero)
	if hero.nParticleEtherealFlameWhite then
		EconRemoveParticle(hero.nParticleEtherealFlameWhite)
	end
end
Econ.OnEquip_ethereal_flame_white_client = Econ.OnEquip_ethereal_flame_white_server
Econ.OnRemove_ethereal_flame_white_client = Econ.OnRemove_ethereal_flame_white_server
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
-- 虚无之焰 金色
Econ.OnEquip_ethereal_flame_golden_server = function(hero)
	if hero.nParticleEtherealFlameGolden then
		EconRemoveParticle(hero.nParticleEtherealFlameGolden)
	end
	hero.nParticleEtherealFlameGolden = EconCreateParticleOnHero(hero, "particles/econ/ethereal_flame.vpcf")
	ParticleManager:SetParticleControl(hero.nParticleEtherealFlameGolden, 15, Vector(217, 191, 89))
	ParticleManager:SetParticleControl(hero.nParticleEtherealFlameGolden, 2, Vector(255, 255, 255))
	ParticleManager:SetParticleControl(hero.nParticleEtherealFlameGolden, 16, Vector(1, 0, 0))
end

Econ.OnRemove_ethereal_flame_golden_server = function(hero)
	if hero.nParticleEtherealFlameGolden then
		EconRemoveParticle(hero.nParticleEtherealFlameGolden)
	end
end
Econ.OnEquip_ethereal_flame_golden_client = Econ.OnEquip_ethereal_flame_golden_server
Econ.OnRemove_ethereal_flame_golden_client = Econ.OnRemove_ethereal_flame_golden_server
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
-- 虚无之焰 粉色
Econ.OnEquip_ethereal_flame_pink_server = function(hero)
	if hero.nParticleEtherealFlamePink then
		EconRemoveParticle(hero.nParticleEtherealFlamePink)
	end
	hero.nParticleEtherealFlamePink = EconCreateParticleOnHero(hero, "particles/econ/ethereal_flame.vpcf")
	ParticleManager:SetParticleControl(hero.nParticleEtherealFlamePink, 15, Vector(210, 0, 210))
	ParticleManager:SetParticleControl(hero.nParticleEtherealFlamePink, 2, Vector(255, 255, 255))
	ParticleManager:SetParticleControl(hero.nParticleEtherealFlamePink, 16, Vector(1, 0, 0))
end

Econ.OnRemove_ethereal_flame_pink_server = function(hero)
	if hero.nParticleEtherealFlamePink then
		EconRemoveParticle(hero.nParticleEtherealFlamePink)
	end
end
Econ.OnEquip_ethereal_flame_pink_client = Econ.OnEquip_ethereal_flame_pink_server
Econ.OnRemove_ethereal_flame_pink_client = Econ.OnRemove_ethereal_flame_pink_server
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- 熔岩之经
Econ.OnEquip_lava_trail_server = function(hero)
	if hero.nParticleLavaTrail then
		EconRemoveParticle(hero.nParticleLavaTrail)
	end
	hero.nParticleLavaTrail = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_trail_lava/courier_trail_lava.vpcf")
end

Econ.OnRemove_lava_trail_server = function(hero)
	if hero.nParticleLavaTrail then
		EconRemoveParticle(hero.nParticleLavaTrail)
	end
end
Econ.OnEquip_lava_trail_client = Econ.OnEquip_lava_trail_server
Econ.OnRemove_lava_trail_client = Econ.OnRemove_lava_trail_server
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- 粒子之气
Econ.OnEquip_paltinum_baby_roshan_server = function(hero)
	if hero.nParticlePBR then
		EconRemoveParticle(hero.nParticlePBR)
	end
	hero.nParticlePBR = EconCreateParticleOnHero(hero, "particles/econ/paltinum_baby_roshan/paltinum_baby_roshan.vpcf")
end
Econ.OnRemove_paltinum_baby_roshan_server = function(hero)
	if hero.nParticlePBR then
		EconRemoveParticle(hero.nParticlePBR)
	end
end
Econ.OnEquip_paltinum_baby_roshan_client = Econ.OnEquip_paltinum_baby_roshan_server
Econ.OnRemove_paltinum_baby_roshan_client = Econ.OnRemove_paltinum_baby_roshan_server
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- 军团之翼
Econ.OnEquip_legion_wings_server = function(hero)
	if hero.nParticleLegionWings then
		EconRemoveParticle(hero.nParticleLegionWings)
	end
	hero.nParticleLegionWings = EconCreateParticleOnHero(hero, "particles/econ/legion_wings/legion_wings.vpcf")
end
Econ.OnRemove_legion_wings_server = function(hero)
	if hero.nParticleLegionWings then
		EconRemoveParticle(hero.nParticleLegionWings)
	end
end
Econ.OnEquip_legion_wings_client = Econ.OnEquip_legion_wings_server
Econ.OnRemove_legion_wings_client = Econ.OnRemove_legion_wings_server
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- 暗月腐化
Econ.OnEquip_darkmoon_server = function(hero)
	if hero.nDarkMoonParticle then
		EconRemoveParticle(hero.nDarkMoonParticle)
	end
	hero.nDarkMoonParticle = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon.vpcf")
	if hero.nDarkMoonParticleGround then
		EconRemoveParticle(hero.nDarkMoonParticleGround)
	end
	hero.nDarkMoonParticleGround = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon_ground.vpcf")
end
Econ.OnRemove_darkmoon_server = function(hero)
	if hero.nDarkMoonParticle then
		EconRemoveParticle(hero.nDarkMoonParticle)
	end
	if hero.nDarkMoonParticleGround then
		EconRemoveParticle(hero.nDarkMoonParticleGround)
	end
end
Econ.OnEquip_darkmoon_client = Econ.OnEquip_darkmoon_server
Econ.OnRemove_darkmoon_client = Econ.OnRemove_darkmoon_server
-----------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------
-- SF Wings
Econ.OnEquip_sf_wings_client = function(hero)
	EconCreateParticleOnHero(hero, "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_wings.vpcf")
end

Econ.OnRemove_sf_wings_client = function(hero) end
Econ.OnEquip_sf_wings_server = function(hero)
	hero.__bSFWingsParticle = true
end

Econ.OnRemove_sf_wings_server = function(hero)
	hero.__bSFWingsParticle = false
end
-----------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
-- 军团之翼 VIP
Econ.OnEquip_legion_wings_vip_server = function(hero)
	if hero.nParticleLegionWingsVip then
		EconRemoveParticle(hero.nParticleLegionWingsVip)
	end
	hero.nParticleLegionWingsVip = EconCreateParticleOnHero(hero, "particles/econ/legion_wings/legion_wings_vip.vpcf")
end
Econ.OnRemove_legion_wings_vip_server = function(hero)
	if hero.nParticleLegionWingsVip then
		EconRemoveParticle(hero.nParticleLegionWingsVip)
	end
end
Econ.OnEquip_legion_wings_vip_client = Econ.OnEquip_legion_wings_vip_server
Econ.OnRemove_legion_wings_vip_client = Econ.OnRemove_legion_wings_vip_server
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
-- 军团之翼 粉色
Econ.OnEquip_legion_wings_pink_server = function(hero)
	if hero.nParticleLegionWingspink then
		EconRemoveParticle(hero.nParticleLegionWingspink)
	end
	hero.nParticleLegionWingspink = EconCreateParticleOnHero(hero, "particles/econ/legion_wings/legion_wings_pink.vpcf")
end
Econ.OnRemove_legion_wings_pink_server = function(hero)
	if hero.nParticleLegionWingspink then
		EconRemoveParticle(hero.nParticleLegionWingspink)
	end
end

-----------------------------------------------------------------------------------------------------------------------
-- Fissured Soul
Econ.OnEquip_sakura_trail_server = function(hero)
	if hero.nParticle_sakura_trail1 then
		EconRemoveParticle(hero.nParticle_sakura_trail1)
	end
	if hero.nParticle_sakura_trail2 then
		EconRemoveParticle(hero.nParticle_sakura_trail2)
	end
	hero.nParticle_sakura_trail1 = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_axolotl_ambient/courier_axolotl_ambient.vpcf")
	hero.nParticle_sakura_trail2 = EconCreateParticleOnHero(hero, "particles/econ/sakura_trail.vpcf")
	ParticleManager:SetParticleControl(hero.nParticle_sakura_trail2,8,Vector(20, 0, 0))
end
Econ.OnRemove_sakura_trail_server = function(hero)
	if hero.nParticle_sakura_trail1 then
		EconRemoveParticle(hero.nParticle_sakura_trail1)
	end
	if hero.nParticle_sakura_trail2 then
		EconRemoveParticle(hero.nParticle_sakura_trail2)
	end
end
Econ.OnEquip_sakura_trail_client = Econ.OnEquip_sakura_trail_server
Econ.OnRemove_sakura_trail_client = Econ.OnRemove_sakura_trail_server

----------------------------------------------------------------------------------------------------------------------------
-- 问号涂鸦
Econ.OnEquip_question_mark_server = function(hero)
	hero.__PszKillMarkParticle = "particles/econ/kill_mark/question_mark.vpcf"
end
Econ.OnRemove_question_mark_server = function(hero)
	if hero.__PszKillMarkParticle == "particles/econ/kill_mark/question_mark.vpcf" then
		hero.__PszKillMarkParticle = nil
	end
end
Econ.OnEquip_question_mark_client = function(hero) end
Econ.OnRemove_question_mark_client = function(hero) end
-----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- 技不如人涂鸦
Econ.OnEquip_jibururen_mark_server = function(hero)
	hero.__PszKillMarkParticle = "particles/econ/kill_mark/jibururen_mark.vpcf"
end
Econ.OnRemove_jibururen_mark_server = function(hero)
	if hero.__PszKillMarkParticle == "particles/econ/kill_mark/jibururen_mark.vpcf" then
		hero.__PszKillMarkParticle = nil
	end
end
Econ.OnEquip_jibururen_mark_client = function(hero) end
Econ.OnRemove_jibururen_mark_client = function(hero) end
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- 滑稽涂鸦
Econ.OnEquip_huaji_server = function(hero)
	hero.__PszKillMarkParticle = "particles/econ/kill_mark/huaji.vpcf"
end
Econ.OnRemove_huaji_server = function(hero)
	if hero.__PszKillMarkParticle == "particles/econ/kill_mark/huaji.vpcf" then
		hero.__PszKillMarkParticle = nil
	end
end
Econ.OnEquip_huaji_client = function(hero) end
Econ.OnRemove_huaji_client = function(hero) end
----------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------
-- 掉钱
Econ.OnEquip_green_server = function(hero)
	if hero.nParticleDroppingGold then
		EconRemoveParticle(hero.nParticleDroppingGold)
	end
	hero.nParticleDroppingGold = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_greevil_green/courier_greevil_green_ambient_3.vpcf")
end
Econ.OnRemove_green_server = function(hero)
	if hero.nParticleDroppingGold then
		EconRemoveParticle(hero.nParticleDroppingGold)
	end
end
Econ.OnEquip_green_client = Econ.OnEquip_green_server
Econ.OnRemove_green_client = Econ.OnRemove_green_server

----------------------------------------------------------------------------------------------------------------------------
-- TI7
Econ.OnEquip_golden_ti7_server = function(hero)
	if hero.nGoldenTI7 then
		EconRemoveParticle(hero.nGoldenTI7)
	end
	hero.nGoldenTI7 = EconCreateParticleOnHero(hero, "particles/econ/golden_ti7.vpcf")
end
Econ.OnRemove_golden_ti7_server = function(hero)
	if hero.nGoldenTI7 then
		EconRemoveParticle(hero.nGoldenTI7)
	end
end
Econ.OnEquip_golden_ti7_client = Econ.OnEquip_golden_ti7_server
Econ.OnRemove_golden_ti7_client = Econ.OnRemove_golden_ti7_server

----------------------------------------------------------------------------------------------------------------------------
-- 恶魔圈
Econ.OnEquip_devil_circle_server = function(hero)
	if hero.nParcielDevilCircle then
		EconRemoveParticle(hero.nParcielDevilCircle)
	end
	hero.nParcielDevilCircle = EconCreateParticleOnHero(hero, "particles/econ/devil_circle.vpcf")
end
Econ.OnRemove_devil_circle_server = function(hero)
	if hero.nParcielDevilCircle then
		EconRemoveParticle(hero.nParcielDevilCircle)
	end
end
Econ.OnEquip_devil_circle_client = Econ.OnEquip_devil_circle_server
Econ.OnRemove_devil_circle_client = Econ.OnRemove_devil_circle_server

----------------------------------------------------------------------------------------------------------------------------
Econ.OnEquip_icey_server = function(hero)
	if hero.nEconParticleIcey then
		EconRemoveParticle(hero.nEconParticleIcey)
	end
	hero.nEconParticleIcey = EconCreateParticleOnHero(hero, "particles/econ/icey.vpcf")
	ParticleManager:SetParticleControlEnt(hero.nEconParticleIcey,1,hero,PATTACH_ABSORIGIN_FOLLOW,"follow_origin",hero:GetAbsOrigin() + hero:GetForwardVector(),true)
end
Econ.OnRemove_icey_server = function(hero)
	if hero.nEconParticleIcey then
		EconRemoveParticle(hero.nEconParticleIcey)
	end
end
Econ.OnEquip_icey_client = Econ.OnEquip_icey_server
Econ.OnRemove_icey_client = Econ.OnRemove_icey_server
----------------------------------------------------------------------------------------------------------------------------
-- 恶魔之翼
Econ.OnEquip_terror_wings_server = function(hero)
	if hero.__EconTerrorWings then
		UTIL_Remove(hero.__EconTerrorWings)
		hero.__EconTerrorWings = nil
	end
	local propModel = 'models/items/terrorblade/terrorblade_ti8_immortal_back/terrorblade_ti8_immortal_back.vmdl'
	local animation = 'terrorblade_ti8_immortal_back_idle'
	local prop = SpawnEntityFromTableSynchronous("prop_dynamic", {model = propModel, DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
	hero.__EconTerrorWings = prop
	prop:FollowEntity(hero, false)
	prop.fx = ParticleManager:CreateParticle('particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_back_ambient_ti8.vpcf', PATTACH_ABSORIGIN, prop)
    ParticleManager:SetParticleControlEnt(prop.fx, 1, prop, PATTACH_POINT_FOLLOW, 'attach_wing_l', prop:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(prop.fx, 2, prop, PATTACH_POINT_FOLLOW, 'attach_wing_r', prop:GetAbsOrigin(), true)
end

Econ.OnRemove_terror_wings_server = function(hero)
	if hero.__EconTerrorWings then
		UTIL_Remove(hero.__EconTerrorWings)
		hero.__EconTerrorWings = nil
	end
end

Econ.OnEquip_terror_wings_client = Econ.OnEquip_terror_wings_server
Econ.OnRemove_terror_wings_client = Econ.OnRemove_terror_wings_server

----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- 生发剂专项赞助，没有效果
Econ.OnEquip_shengfaji_server = function(hero) end
Econ.OnRemove_shengfaji_server = function(hero) end
Econ.OnEquip_shengfaji_client = function(hero) end
Econ.OnRemove_shengfaji_client = function(hero) end
----------------------------------------------------------------------------------------------------------------------------
-- 斗鱼的标签
Econ.OnEquip_dy_label_server = function(hero)
    if hero._econDouyuPcf then
    	ParticleManager:DestroyParticle(hero._econDouyuPcf, true)
    end

    local steamid = PlayerResource:GetSteamAccountID(hero:GetPlayerID())
    local pcf
    if steamid == 101678979 or steamid == 87584295
        or steamid == 86815341
        then
        pcf = "particles/econ/douyu_1.vpcf"
    elseif steamid == 377420354 or steamid == 110331098
        then
        pcf = "particles/econ/douyu_2.vpcf"
    elseif steamid == 106579277 or steamid == 133571218
        then
        pcf = "particles/econ/douyu_3.vpcf"
    end
    if pcf and hero._econDouyuPcf == nil then
        hero._econDouyuPcf = ParticleManager:CreateParticle(pcf, PATTACH_OVERHEAD_FOLLOW, hero)
    end
end

Econ.OnRemove_dy_label_server = function(hero)
	if hero._econDouyuPcf then
    	ParticleManager:DestroyParticle(hero._econDouyuPcf, true)
    	hero._econDouyuPcf = nil
    end
end

----------------------------------------------------------------------------------------------------------------------------

Econ.OnEquip_pd_label_server = function(hero)
	local pd_label_data = {
		-- 1 赤壁的妖术师
		-- 2 最强
		-- 3 宗师
		-- 4 斗帝
		-- 5 仙灵女巫
		-- 6 大师
		[90137663]  =	"pd_label_4",
		[86869350]  =	"pd_label_3",
		[135611599] =	"pd_label_4",
		[140178149] =	"pd_label_3",
		[360421282] =	"pd_label_6",
		[162382904] =	"pd_label_6",
		[180982687] =	"pd_label_1",
		[130978745] =	"pd_label_1",
		[208162986] =	"pd_label_5",
		[204780203] =	"pd_label_5",
		[160344678] =	"pd_label_6",
		[407868413] =	"pd_label_6",
		[195337130] =	"pd_label_6",
		[431839322] =	"pd_label_6",
		[279979404] =	"pd_label_6",
		[365609542] =	"pd_label_6",
		[245889228] =	"pd_label_6",
		[160041700] =	"pd_label_6",
		[245389915] =	"pd_label_6",
		[328817800] =	"pd_label_6",
		[108985322] =	"pd_label_5",
		[211228393] =	"pd_label_2",
		[139311571] =	"pd_label_2",
		[84418494]  =	"pd_label_5",
		[297013446] =	"pd_label_3",
		[140153524] =	"pd_label_2",
	}

	if hero._econPDPcf then
    	ParticleManager:DestroyParticle(hero._econPDPcf, true)
    end

	local steamid = PlayerResource:GetSteamAccountID(hero:GetPlayerID())
    if pd_label_data[steamid] ~= nil then
    	hero._econPDPcf = ParticleManager:CreateParticle("particles/econ/" .. pd_label_data[steamid] .. ".vpcf", PATTACH_OVERHEAD_FOLLOW, hero)
    end
end
Econ.OnRemove_pd_label_server = function(hero)
	if hero._econPDPcf then
    	ParticleManager:DestroyParticle(hero._econPDPcf, true)
    	hero._econPDPcf = nil
    end
end

----------------------------------------------------------------------------------------------------------------------------
-- 火猫的标签
Econ.OnEquip_hm_label_server = function(hero)
	if hero._econHMLabel then
    	ParticleManager:DestroyParticle(hero._econHMLabel, true)
    end
    hero._econHMLabel = ParticleManager:CreateParticle("particles/econ/hm_label.vpcf", PATTACH_OVERHEAD_FOLLOW, hero)
end
Econ.OnRemove_hm_label_server = function(hero)
	if hero._econHMLabel then
    	ParticleManager:DestroyParticle(hero._econHMLabel, true)
    	hero._econHMLabel = nil
    end
end

----------------------------------------------------------------------------------------------------------------------------
-- 冷库少年
Econ.OnEquip_label_lksn_server = function(hero)
	if hero._econ_label_lksn then
    	ParticleManager:DestroyParticle(hero._econ_label_lksn, true)
    end
    hero._econ_label_lksn = ParticleManager:CreateParticle("particles/econ/label_lksn.vpcf", PATTACH_OVERHEAD_FOLLOW, hero)
end
Econ.OnRemove_label_lksn_server = function(hero)
	if hero._econ_label_lksn then
    	ParticleManager:DestroyParticle(hero._econ_label_lksn, true)
    	hero._econ_label_lksn = nil
    end
end
Econ.OnEquip_label_mmfs_server = function(hero)
	if hero._econ_label_mmfs then
    	ParticleManager:DestroyParticle(hero._econ_label_mmfs, true)
    end
    hero._econ_label_mmfs = ParticleManager:CreateParticle("particles/econ/label_mmfs.vpcf", PATTACH_OVERHEAD_FOLLOW, hero)
end
Econ.OnRemove_label_mmfs_server = function(hero)
	if hero._econ_label_mmfs then
    	ParticleManager:DestroyParticle(hero._econ_label_mmfs, true)
    	hero._econ_label_mmfs = nil
    end
end
Econ.OnEquip_label_bznh_server = function(hero)
	if hero._econ_label_bznh then
    	ParticleManager:DestroyParticle(hero._econ_label_bznh, true)
    end
    hero._econ_label_bznh = ParticleManager:CreateParticle("particles/econ/label_bznh.vpcf", PATTACH_OVERHEAD_FOLLOW, hero)
end
Econ.OnRemove_label_bznh_server = function(hero)
	if hero._econ_label_bznh then
    	ParticleManager:DestroyParticle(hero._econ_label_bznh, true)
    	hero._econ_label_bznh = nil
    end
end
-- 天梯排名前几名的奖励
local function createEconLabel(name)
	Econ['OnEquip_' .. name .. '_server'] = function(hero)
		if hero['_econLabel' .. name] then
			ParticleManager:DestroyParticle(hero['_econLabel' .. name], true)
		end

		hero['_econLabel' .. name] = ParticleManager:CreateParticle('particles/econ/' .. name .. '.vpcf', PATTACH_OVERHEAD_FOLLOW, hero)
	end

	Econ['OnRemove_' .. name .. '_server'] = function(hero)
		if hero['_econLabel' .. name] then
	    	ParticleManager:DestroyParticle(hero['_econLabel' .. name], true)
	    	hero['_econLabel' .. name] = nil
	    end
	end
end

createEconLabel('rank_top1')
createEconLabel('rank_top2')
createEconLabel('rank_top3')
createEconLabel('rank_top10')
createEconLabel('rank_top20')

createEconLabel('dy_new_1')
createEconLabel('dy_new_2')
createEconLabel('dy_new_3')

----------------------------------------------------------------------------------------------------------------------------
-- 富可敌国
Econ.OnEquip_rich_server = function(hero)
	if hero._econRichPCF then
    	ParticleManager:DestroyParticle(hero._econRichPCF, true)
    end
    hero._econRichPCF = ParticleManager:CreateParticle("particles/econ/rich.vpcf", PATTACH_OVERHEAD_FOLLOW, hero)
end
Econ.OnRemove_rich_server = function(hero)
	if hero._econRichPCF then
    	ParticleManager:DestroyParticle(hero._econRichPCF, true)
    	hero._econRichPCF = nil
    end
end
----------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------
-- 虚无之焰
Econ.OnEquip_ethereal_flame_server = function(hero)
	if hero.nParcielEtherealFlame then
		EconRemoveParticle(hero.nParcielEtherealFlame)
	end
	hero.nParcielEtherealFlame = EconCreateParticleOnHero(hero, "particles/econ/ethereal_flame.vpcf")
    local steamid = PlayerResource:GetSteamAccountID(hero:GetPlayerID())
    local c = {207,171,49}
    c = ({
    	['86815341'] = {130,50,237}
	})[tostring(steamid)]
    ParticleManager:SetParticleControl(hero.nParcielEtherealFlame, 2, Vector(c[1],c[2],c[3]))
    ParticleManager:SetParticleControl(hero.nParcielEtherealFlame, 15, Vector(c[1],c[2],c[3]))
    ParticleManager:SetParticleControl(hero.nParcielEtherealFlame, 16, Vector(1,0,0))
end
Econ.OnRemove_ethereal_flame_server = function(hero)
	if hero.nParcielEtherealFlame then
		EconRemoveParticle(hero.nParcielEtherealFlame)
	end
end
Econ.OnEquip_ethereal_flame_client = Econ.OnEquip_ethereal_flame_server
Econ.OnRemove_ethereal_flame_client = Econ.OnRemove_ethereal_flame_server
----------------------------------------------------------------------------------------------------------------------------



if not IsServer() then return end

if EconManager == nil then EconManager = class({}) end

function EconManager:constructor()
	CustomGameEventManager:RegisterListener("bom_player_equip",function(_, keys)
		self:OnPlayerEquip(keys)
	end)
	CustomGameEventManager:RegisterListener("bom_player_preview",function(_, keys)
		self:OnPlayerPreview(keys)
	end)
	
	-- 所有的数据都从服务器发
	CustomGameEventManager:RegisterListener("bom_player_ask_shop_items", function(_, keys)
		self:OnPlayerAskShopItems(keys)
	end)
	CustomGameEventManager:RegisterListener("bom_player_ask_point_history", function(_, keys)
		self:OnPlayerAskPointHistory(keys)
	end)
	CustomGameEventManager:RegisterListener("bom_player_purchase", function(_, keys)
		self:OnPlayerPurchase(keys)
	end)
	CustomGameEventManager:RegisterListener("bom_player_ask_collection", function(_, keys)
		self:OnPlayerAskCollection(keys)
	end)
end

function EconManager:OnPlayerPreview(keys)
	local playerid = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerid)
	if not player then return end
	local hero = player:GetAssignedHero()
	if not hero then return end

	local name = keys.item

	if Econ["OnEquip_" .. name .. "_server"] then
		Econ["OnEquip_" .. name .. "_server"](hero)
	end

	Timer(10, function()
		Econ["OnRemove_" .. name .. "_server"](hero)
	end)
end

function EconManager:OnPlayerEquip(keys)
	local playerid = keys.PlayerID
	local steamid = PlayerResource:GetSteamAccountID(playerid)
	local items = keys.items
	local req = CreateHTTPRequestScriptVM('POST', 'http://yueyutech.com:10010/PlayerEquip')
	req:SetHTTPRequestGetOrPostParameter('steamid', tostring(steamid))
	req:SetHTTPRequestGetOrPostParameter('items', tostring(items))
	req:Send(function(result)
		if result.StatusCode == 200 then
			self:OnPlayerAskCollection({PlayerID = playerid})
		end
	end)
end

function EconManager:OnPlayerAskCollection(keys)
	local playerid = keys.PlayerID
	local player = PlayerResource:GetPlayer(playerid)
	if not player then return end
	local hero = player:GetAssignedHero()
	if not hero then return end

	local steamid = PlayerResource:GetSteamAccountID(playerid)
	local req = CreateHTTPRequestScriptVM("POST","http://yueyutech.com:10010/GetCollection")
	req:SetHTTPRequestGetOrPostParameter("steamid",tostring(steamid))
	req:Send(function(result)
		if result.StatusCode == 200 then
			local data = JSON:decode(result.Body)
			for name, equip in pairs(data) do
				if name ~= 'steamid' then
					if equip == true then
						if Econ["OnEquip_" .. name .. "_server"] then
							Econ["OnEquip_" .. name .. "_server"](hero)
						end
					else
						if Econ["OnRemove_" .. name .. "_server"] then
							Econ["OnRemove_" .. name .. "_server"](hero)
						end
					end
				end
			end
			CustomNetTables:SetTableValue('econ_data', 'collection_data_' .. playerid, data)
		end
	end)
end

function EconManager:OnPlayerAskShopItems(keys)
	if self.vEconItems == nil then 
		local req = CreateHTTPRequestScriptVM('POST', 'http://yueyutech.com:10010/GetShopItems')
		req:Send(function(result)
			if result.StatusCode == 200 then
				local items = JSON:decode(result.Body)
				self.vEconItems = items
				CustomNetTables:SetTableValue('econ_data', 'shop_items', items)
			end
		end)
	end
end

function EconManager:OnPlayerAskPointHistory(keys)
	local id = keys.PlayerID
	local steamid = PlayerResource:GetSteamAccountID(id)

	local req = CreateHTTPRequestScriptVM('POST', 'http://yueyutech.com:10010/GetPoints')
	req:SetHTTPRequestGetOrPostParameter('steamid', tostring(steamid))
	req:Send(function(result)
		if result.StatusCode == 200 then
			CustomNetTables:SetTableValue('econ_data', 'point_history_' .. id, JSON:decode(result.Body));
		end
	end)
end

function EconManager:OnPlayerPurchase(keys)
	local id = keys.PlayerID
	local item = keys.ItemName
	local steamid = PlayerResource:GetSteamAccountID(id)
	local req = CreateHTTPRequestScriptVM('POST', 'http://yueyutech.com:10010/Purchase')
	req:SetHTTPRequestGetOrPostParameter('steamid', tostring(steamid))
	req:SetHTTPRequestGetOrPostParameter('item', tostring(item))
	req:Send(function(result)
		if result.StatusCode == 200 then
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(id), 'bom_player_purchase_message', {})
		end
		self:OnPlayerAskCollection({PlayerID=id})
	end)
end


if GameRules.EconManager == nil then GameRules.EconManager = EconManager() end

