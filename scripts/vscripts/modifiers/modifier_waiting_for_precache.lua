modifier_waiting_for_precache = class({})

function modifier_waiting_for_precache:IsHidden()
    return false
end

function modifier_waiting_for_precache:GetTexture()
    return 'modifiers/loading'
end

function modifier_waiting_for_precache:OnCreated(kv)
    if IsServer() then
        local nFXIndex = ParticleManager:CreateParticle( "particles/items_fx/glyph_creeps.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "follow_origin", self:GetCaster():GetOrigin(), true )
        self:AddParticle( nFXIndex, false, false, -1, false, true )

        self:SetDuration(20, true)
    end
end

function modifier_waiting_for_precache:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_ROOTED] = true,
    }
end

function modifier_waiting_for_precache:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end

function modifier_waiting_for_precache:GetModifierInvisibilityLevel()
    return 1
end