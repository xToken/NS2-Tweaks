// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\Shared\SkulkAdjustments.lua
// - Dragon

local Shared_TraceRay = Shared.TraceRay
function WallMovementMixin:GetAverageWallWalkingNormal(extraRange, feelerSize)

    PROFILE("WallMovementMixin:GetAverageWallWalkingNormal")
    
    local startPoint = Vector(self:GetOrigin())
    local extents = self:GetExtents()
    startPoint.y = startPoint.y + extents.y

    local numTraces = 8
	local numVertTraces = 4
    local wallNormals = {}

    // Trace in a circle around self, looking for walls we hit
    local wallWalkingRange = math.max(extents.x, extents.y) + extraRange
    local endPoint = Vector()
    local directionVector
    local angle
    local normalFound = true
    
    if not self.lastSuccessfullWallTraceDir or not self:TraceWallNormal(startPoint, startPoint + self.lastSuccessfullWallTraceDir * wallWalkingRange, wallNormals, feelerSize) then

        normalFound = false

        for i = 0, numTraces - 1 do
        
            angle = ((i * 360/numTraces) / 360) * math.pi * 2
            directionVector = Vector(math.cos(angle), 0, math.sin(angle))
            
            // Avoid excess vector creation
            endPoint.x = startPoint.x + directionVector.x * wallWalkingRange
            endPoint.y = startPoint.y
            endPoint.z = startPoint.z + directionVector.z * wallWalkingRange
            
            if self:TraceWallNormal(startPoint, endPoint, wallNormals, feelerSize) then
            
                self.lastSuccessfullWallTraceDir = directionVector
                normalFound = true
                break
                
            end   
            
        end
    
    end
	
	if not normalFound then
		//Try traces upwards
		endPoint = Vector()
		for i = 0, numVertTraces - 1 do
        
            angle = ((i * 360/numTraces) / 360) * math.pi * 2
            directionVector = Vector(math.cos(angle), 0, math.sin(angle))
			
			endPoint.x = startPoint.x + directionVector.x * wallWalkingRange
            endPoint.y = startPoint.y + wallWalkingRange
            endPoint.z = startPoint.z + directionVector.z * wallWalkingRange
            
            if self:TraceWallNormal(startPoint, endPoint, wallNormals, feelerSize) then
            
                self.lastSuccessfullWallTraceDir = directionVector
                normalFound = true
                break
                
            end
			
		end
		
	end
    
    // Trace above too.
    if not normalFound then
        normalFound = self:TraceWallNormal(startPoint, startPoint + Vector(0, wallWalkingRange, 0), wallNormals, feelerSize)
    end

    if normalFound then
    
        // Check if we are right above a surface we can stand on.
        // Even if we are in "wall walking mode", we want it to look
        // like it is standing on a surface if it is right above it.
        local groundTrace = Shared_TraceRay(startPoint, startPoint + Vector(0, -wallWalkingRange, 0), CollisionRep.Move, PhysicsMask.AllButPCs, EntityFilterOne(self))
        if (groundTrace.fraction > 0 and groundTrace.fraction < 1 and groundTrace.entity == nil) then
            return groundTrace.normal
        end
        
        return wallNormals[1]
        
    end
    
    return nil
    
end