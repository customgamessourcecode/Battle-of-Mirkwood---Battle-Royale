utilsDamage = {}

---对玩家造成总生命值百分比的伤害
---@param source CDOTA_BaseNPC
---@param target CDOTA_BaseNPC
---@param damage_percentage number
---@param ability CDOTA_Ability_Lua
function utilsDamage.DealDamagePercentage(source, target, damage_percentage, ability, damageType)
    local damage_value = damage_percentage * target:GetMaxHealth() / 100
    ApplyDamage({
                    attacker    = source,
                    victim      = target,
                    damage      = damage_value,
                    damage_type = damageType or DAMAGE_TYPE_PURE,
                    ability     = ability
                })
end

function KVDealDamagePercentage(keys)
    local source        = keys.caster
    local target        = keys.target
    local damage_percentage = keys.DamagePercentage
    utilsDamage.DealDamagePercentage(source, target, damage_percentage, keys.ability)
end

function utilsDamage.DealDamageConstant(source, target, damage_amount, ability, damageType)
    ApplyDamage({
                    attacker    = source,
                    victim      = target,
                    damage      = damage_amount,
                    ability     = ability,
                    damage_type = damageType or DAMAGE_TYPE_PURE,
                })
end