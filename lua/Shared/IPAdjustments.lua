// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\Shared\IPAdjustments.lua
// - Dragon

local kIpPushDirections = 8
//This isnt foolproof, but should cut down on the sillyness a bit.
local function PushPlayers(self)

	self.lastPush = self.lastPush or 0
    for _, player in ipairs(GetEntitiesWithinRange("Player", self:GetOrigin(), 1)) do
		if player:GetIsAlive() and HasMixin(player, "GroundMove") then
			local trace = Shared.TraceRay(player:GetOrigin(), player:GetOrigin() - Vector(0, 1, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterOne(player))
			if trace.fraction < 1 and trace.entity and trace.entity == self then
				local angle = ((self.lastPush * 360 / kIpPushDirections) / 360) * math.pi * 2
				player:DisableGroundMove(0.1)
				player:SetVelocity(Vector(math.cos(angle) * 3, 3, math.sin(angle) * 3))
				self.lastPush = (self.lastPush + 1) % kIpPushDirections
			end
		end
    end

end

local function InfantryPortalUpdate(self)

    self:FillQueueIfFree()
    
    if GetIsUnitActive(self) then
        
        local remainingSpawnTime = self:GetSpawnTime()
        if self.queuedPlayerId ~= Entity.invalidId then
        
            local queuedPlayer = Shared.GetEntity(self.queuedPlayerId)
            if queuedPlayer then
            
                remainingSpawnTime = math.max(0, self.queuedPlayerStartTime + self:GetSpawnTime() - Shared.GetTime())
            
                if remainingSpawnTime > 0 and remainingSpawnTime < 1 and self.timeLastPush + 0.5 < Shared.GetTime() then
                
                    PushPlayers(self)
                    self.timeLastPush = Shared.GetTime()
                    
                end
                
            else
            
                self.queuedPlayerId = nil
                self.queuedPlayerStartTime = nil
                
            end

        end
    
        if remainingSpawnTime == 0 then
            self:FinishSpawn()
        end
        
        // Stop spinning if player left server, switched teams, etc.
        if self.timeSpinUpStarted and self.queuedPlayerId == Entity.invalidId then
            StopSpinning(self)
        end
        
    end
    
    return true
    
end

ReplaceLocals(InfantryPortal.OnInitialized, { InfantryPortalUpdate = InfantryPortalUpdate })