// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\NS2-Tweaks_FileHooks.lua
// - Dragon

//Filehooks
//Add in manually.
//Better Doors
ModLoader.SetupFileHook( "lua/Door.lua", "lua/Replace/Door.lua", "replace" )
//Fix for buildfraction gitter.
ModLoader.SetupFileHook( "lua/ConstructMixin.lua", "lua/Post/ConstructMixin.lua", "post" )
//Predict Collision fixes 'lib' needs to know when Predict VM is fully loaded.  No such callback exists afaik.
if Predict then
	ModLoader.SetupFileHook( "lua/PostLoadMod.lua", "lua/Predict/predict_loaded.lua", "post" )
end