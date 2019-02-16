function OnSoulLight(keys)
	local caster = keys.caster
	local target = keys.target
	local lightning = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, target)
	local loc = target:GetAbsOrigin()
	ParticleManager:SetParticleControl(lightning, 0, loc + Vector(0, 0, 1000))
	ParticleManager:SetParticleControl(lightning, 1, loc)
	ParticleManager:SetParticleControl(lightning, 2, loc)
	ParticleManager:ReleaseParticleIndex(lightning)
end
