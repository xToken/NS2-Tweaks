// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\Shared\AlienTechTreeAdjustments.lua
// - Dragon

if Server then

	//Fix for Harvester's take a couple ticks of damage at round start sometimes.  Infestation updates on a slower HZ, so run one manually here.
	local function CreateCysts(hive, harvester, teamNumber)

		local hiveOrigin = hive:GetOrigin()
		local harvesterOrigin = harvester:GetOrigin()
		
		// Spawn all the Cyst spawn points close to the hive.
		local dist = (hiveOrigin - harvesterOrigin):GetLength()
		for c = 1, #Server.cystSpawnPoints do
		
			local spawnPoint = Server.cystSpawnPoints[c]
			if (spawnPoint - hiveOrigin):GetLength() <= (dist * 1.5) then
			
				local cyst = CreateEntityForTeam(kTechId.Cyst, spawnPoint, teamNumber, nil)
				cyst:SetConstructionComplete()
				cyst:SetInfestationFullyGrown()
				cyst:SetImmuneToRedeploymentTime(1)
				cyst:UpdateInfestation()
				
			end
			
		end
		
	end

	ReplaceLocals(AlienTeam.SpawnInitialStructures, { CreateCysts = CreateCysts })
	
end