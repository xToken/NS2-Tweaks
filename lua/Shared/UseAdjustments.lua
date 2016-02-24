// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\Shared\UseAdjustments.lua
// - Dragon

Script.Load("lua/Class.lua")

local function AttemptToUse(self, timePassed)

    PROFILE("Player:AttemptToUse")
    
    assert(timePassed >= 0)
	local t = Shared.GetTime()
    
    if (t - self.timeOfLastUse) < kUseInterval then
        return false
    end
    
    -- Cannot use anything unless playing the game (a non-spectating player).
    if not self:GetIsOnPlayingTeam() then
        return false
    end
    
    if GetIsVortexed(self) then
        return false
    end
    
    -- Trace to find use entity.
    local entity, usablePoint = self:PerformUseTrace()
    
    -- Use it.
    if entity then
    
        -- if the game isn't started yet, check if the entity is usuable in non-started game
        -- (allows players to select commanders before the game has started)
        if not self:GetGameStarted() and not (entity.GetUseAllowedBeforeGameStart and entity:GetUseAllowedBeforeGameStart()) then
            return false
        end
        
		local dt = t - self.timeOfLastUse
		if not self.isUsing then
			dt = kUseInterval
		end
        -- Use it.
        if self:UseTarget(entity, dt) then
        
            self:SetIsUsing(true)
            self.timeOfLastUse = t
            return true
            
        end
        
    end
    
end

ReplaceLocals(Player.HandleButtons, { AttemptToUse = AttemptToUse })