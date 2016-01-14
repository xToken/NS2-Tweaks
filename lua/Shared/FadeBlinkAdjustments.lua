// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\Shared\FadeBlinkAdjustments.lua
// - Dragon

if Client then

	function Fade:UpdateClientEffects(deltaTime, isLocal)
		
		Alien.UpdateClientEffects(self, deltaTime, isLocal)

		if not self.trailCinematic then
			self:CreateTrailCinematic()
		end
		
		local showTrail = (self:GetIsBlinking() or self:GetIsShadowStepping()) and (not isLocal or self:GetIsThirdPerson())
		
		self.trailCinematic:SetIsVisible(showTrail)
		self.scanTrailCinematic:SetIsVisible(showTrail and self.isScanned)
		
		if self:GetIsAlive() then
		
			if self:GetIsShadowStepping() then
				self.blinkDissolve = 1    
			elseif self:GetIsBlinking() then
				self.blinkDissolve = 0.6
				self.wasBlinking = true
			else
			
				if self.wasBlinking then
					self.wasBlinking = false
					self.blinkDissolve = 1
				end    
			
				self.blinkDissolve = math.max(0, self.blinkDissolve - deltaTime)
			end
		
		else
			self.blinkDissolve = 0
		end  
		
		
		self:UpdateBlink2DSound(isLocal)
		
	end

	function Fade:UpdateBlink2DSound(isLocal)

		local playSound = self:GetIsBlinking() and not GetHasSilenceUpgrade(self) and isLocal

		if playSound and not self.blinkSoundPlaying then
		
			self:TriggerEffects("blink_loop_start")
			self.blinkSoundPlaying = true
			
		elseif not playSound and self.blinkSoundPlaying then
		
			self:TriggerEffects("blink_loop_end")
			self.blinkSoundPlaying = false
			
		end

	end
		
end

local function TriggerBlinkOutEffects(self, player)

	// Afaik, Shared.GetIsRunningPrediction no longer actually works...
    if not Shared.GetIsRunningPrediction() then
    
        player:TriggerEffects("blink_out", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})
        
    end
    
end

ReplaceLocals(Blink.SetEthereal, { TriggerBlinkOutEffects = TriggerBlinkOutEffects })