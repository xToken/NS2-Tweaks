// Natural Selection 2 'Tweaks' Mod
// Source located at - https://github.com/xToken/NS2-Tweaks
// lua\Shared\CatPackAdjustments.lua
// - Dragon

//Fix for catpacks being picked up while still having catalyst.
local originalMarineGetCanUseCatPack
originalMarineGetCanUseCatPack = Class_ReplaceMethod("Marine", "GetCanUseCatPack",
	function(self)
		return not self.catpackboost
	end
)

local originalExoGetCanUseCatPack
originalExoGetCanUseCatPack = Class_ReplaceMethod("Exo", "GetCanUseCatPack",
	function(self)
		return not self.catpackboost
	end
)