modifier_respawn_bonus = class({})

function modifier_respawn_bonus:IsHidden()
    return false
end

function modifier_respawn_bonus:GetTextureName()
    return "rune_doubledamage"
end

function modifier_respawn_bonus:OnCreated(kv)
    if IsServer() then
        local nFXIndex = ParticleManager:CreateParticle( "particles/items_fx/glyph_creeps.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "follow_origin", self:GetCaster():GetOrigin(), true )
        self:AddParticle( nFXIndex, false, false, -1, false, true )
        self:SetDuration(5,true)
    end
end

function modifier_respawn_bonus:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
    }
    return funcs
end

--------------------------------------------------------------------------------

function modifier_respawn_bonus:OnAttackLanded( params )
    if IsServer() then
        self:Destroy()
    end
    return 0
end

function modifier_respawn_bonus:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_respawn_bonus:GetModifierInvisibilityLevel()
    return 1
end


function modifier_respawn_bonus:GetModifierMoveSpeedBonus_Constant()
    return 300
end

function modifier_respawn_bonus:GetModifierMoveSpeed_Limit()
    return 1500
end

function modifier_respawn_bonus:GetModifierMoveSpeed_Max()
    return 1500
end

function modifier_respawn_bonus:GetDisableAutoAttack()
    return 1
end