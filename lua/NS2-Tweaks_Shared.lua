// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\NS2-Tweaks_Shared.lua
// - Dragon

//Base 'Shared' changes which apply to all VMs

Script.Load( "lua/Class.lua" )

local MainFiles = { }
Shared.GetMatchingFileNames( "lua/Shared/*.lua", true, MainFiles )

//Load function changes
for i = 1, #MainFiles do
	Script.Load(MainFiles[i])
end