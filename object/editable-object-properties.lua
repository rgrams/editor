
local M = {}

local constructArgs = require "object.class-constructor-args"
local classList = constructArgs.classList
local setget = require "object.object-prop-set-getters"
local set, get = setget.set, setget.get
local defAssets = require "defaultAssets.list"

local NO_DEFAULT = constructArgs.NO_DEFAULT

function M.getSpecs(className, propName)
	local t = M[className] or M.Object
	for i,v in ipairs(t) do
		if v[1] == propName then
			return v
		end
	end
end

M.displayNames = { kx = "shear x", ky = "shear y" }

-- Properties that all objects have:
M.universalProperties = {
	-- { key, defaultVal, type, setter, getter }
	{ "name", nil, "string"},
	{ "path", nil, "read-only" },
	{ "layer", nil, "string" }, -- Should be multiple-choice at some point.
	{ "script", nil, "list" },
}

M.Object = {
	-- { key, defaultVal, type, setter, getter }
	{ "pos", {x=0,y=0}, "vector2" },
	{ "angle", 0, "number" },
	{ "sx", 0, "number" },
	{ "sy", 0, "number" },
	{ "kx", 0, "number" },
	{ "ky", 0, "number" }
}

M.Sprite = {
	-- { key, defaultVal, type, setter, getter }
	{ "image", NO_DEFAULT, "string", set.imageData, get.assetParams, defAssets.image},
	{ "pos", {x=0,y=0}, "vector2" },
	{ "angle", 0, "number" },
	{ "sx", 0, "number" },
	{ "sy", 0, "number" },
	{ "color", {1,1,1,1}, "color"},
	{ "ox", 0, "number", set.imgOffsetFraction, get.imgOffsetFraction },
	{ "oy", 0, "number", set.imgOffsetFraction, get.imgOffsetFraction },
	{ "kx", 0, "number" },
	{ "ky", 0, "number" }
}

M.Text = {
	-- { key, defaultVal, type, setter, getter }
	{ "text", "", "string"},
	{ "font", NO_DEFAULT, "font", set.font, get.assetParams, defAssets.font},
	{ "pos", {x=0,y=0}, "vector2" },
	{ "angle", 0, "number" },
	{ "wrapLimit", nil, "number" },
	{ "hAlign", "left", "string" },
	{ "sx", 0, "number" },
	{ "sy", 0, "number" },
	{ "kx", 0, "number" },
	{ "ky", 0, "number" }
}

M.Quad = {
	-- { key, defaultVal, type, setter, getter }
	{ "image", NO_DEFAULT, "string", set.imageData, get.assetParams, defAssets.image },
	{ "quad", NO_DEFAULT, "quad", set.quadParams, get.quadParams, defAssets.quad },
	{ "pos", {x=0,y=0}, "vector2" },
	{ "angle", 0, "number" },
	{ "sx", 0, "number" },
	{ "sy", 0, "number" },
	{ "color", {1,1,1,1}, "color"},
	{ "ox", 0, "number", set.imgOffsetFraction, get.imgOffsetFraction },
	{ "oy", 0, "number", set.imgOffsetFraction, get.imgOffsetFraction },
	{ "kx", 0, "number" },
	{ "ky", 0, "number" }
}

M.World = {
	-- { key, defaultVal, type, setter, getter }
	{ "xg", 0, "number", set.gravity, get.gravity },
	{ "yg", 0, "number", set.gravity, get.gravity },
	{ "sleep", false, "bool", set.sleepingAllowed, get.sleepingAllowed },
	{ "disableBegin", false, "bool", set.worldCallbackEnabled, get.worldCallbackEnabled },
	{ "disableEnd", false, "bool", set.worldCallbackEnabled, get.worldCallbackEnabled },
	{ "disablePre", false, "bool", set.worldCallbackEnabled, get.worldCallbackEnabled },
	{ "disablePost", false, "bool", set.worldCallbackEnabled, get.worldCallbackEnabled },
}

-- Property widgets:
-- 	Numeric input box.
--		String input box.
-- 	Read-only string.
--		XY-Vector input boxes.
--		4-value Color input boxes. (limit to 0-1?)
			-- Have a colorpicker eventually.
--		String arrays. (`script`)

return M
