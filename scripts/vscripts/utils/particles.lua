utilsParticle = {}

function utilsParticle.CreateParticleOnHitLoc(particle, target)
	local pid = ParticleManager:CreateParticle(particle,PATTACH_POINT_FOLLOW,target)
	for i = 1, 15 do
		ParticleManager:SetParticleControlEnt(pid, i, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	end
	ParticleManager:ReleaseParticleIndex(pid)
end

function utilsParticle.CreateParticleOverhead(particle, target)
	local pid = ParticleManager:CreateParticle(particle,PATTACH_OVERHEAD_FOLLOW,target)
	for i = 1, 15 do
		ParticleManager:SetParticleControlEnt(pid, i, target, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", target:GetAbsOrigin(), false)
	end
	ParticleManager:ReleaseParticleIndex(pid)
end