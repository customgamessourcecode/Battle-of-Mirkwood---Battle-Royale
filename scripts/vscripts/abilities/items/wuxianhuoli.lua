LinkLuaModifier("modifier_wuxianhuoli_lua","abilities/items/modifiers/modifier_wuxianhuoli_lua.lua",LUA_MODIFIER_MOTION_NONE)

function AttachLuaModifier(keys)
	local caster = keys.caster
	caster:AddNewModifier(caster,keys.ability,"modifier_wuxianhuoli_lua",{})
end