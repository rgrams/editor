
local M = {}

local setget = require "object.object-prop-set-getters"
local set, get = setget.set, setget.get
local defAssets = require "defaultAssets.list"

local NO_DEFAULT = {}
M.NO_DEFAULT = NO_DEFAULT
M.classList = { "Object", "Sprite", "Text", "Quad", "World" }
M.stringToClass = {
	Object = Object, Sprite = Sprite, Text = Text, Quad = Quad, World = World
}
M.constructArgs = {}
M.minimumConstructArgs = {}

function M.areValuesEqual(a, b)
	if a == b then  return true  end
	if type(a) == "table" and type(b) == "table" then
		for k,v in pairs(a) do
			if b[k] ~= v then  return  end
		end
		return true
	end
end

function M.getSpecs(className, propName)
	local classPropList = M[className] or M.Object
	return classPropList[propName]
end

function M.getDefault(className, key, subKey)
	local propData = (M[className] or M.Object)[key]
	local defaultVal = propData[1]
	if subKey then  defaultVal = defaultVal[subKey]  end
	return defaultVal, propData[5]
end

function M.getValue(obj, key, subKey)
	local propList = M[obj.className] or M.Object
	local getter = propList[key][4] or get.default
	return getter(obj, key, subKey)
end

function M.setValue(obj, key, val, subKey)
	local propList = M[obj.className] or M.Object
	assert(propList[key], "Obj-Properties.setValue - No property: '" .. tostring(key) .. "' for object of class '" .. obj.className .. "'.")
	local setter = propList[key][3] or set.default
	setter(obj, key, val, subKey)
end

M.displayNames = { kx = "shear x", ky = "shear y" }

-- Properties that all objects have:
M.universalProps = {
	-- key = { defaultVal, type, setter, getter }
	name = { nil, "string"},
	path = { nil, "read-only" },
	layer = { nil, "string" }, -- Should be multiple-choice at some point.
	script = { nil, "list" },
}

M.Object = {
	-- key = { defaultVal, type, setter, getter }
	pos = { {x=0,y=0}, "vector2", set.pos, get.pos },
	angle = { 0, "number" },
	sx = { 1, "number" },
	sy = { 1, "number" },
	kx = { 0, "number" },
	ky = { 0, "number" }
}
M.constructArgs.Object = {
	{"pos", "x"}, {"pos", "y"}, {"angle"},
	{"sx"}, {"sy"}, {"kx"}, {"ky"}
}

M.Sprite = {
	-- key = { defaultVal, type, setter, getter }
	image = { NO_DEFAULT, "string", set.imageData, get.assetParams, defAssets.image},
	pos = { {x=0,y=0}, "vector2", set.pos, get.pos },
	angle = { 0, "number" },
	sx = { 1, "number" },
	sy = { 1, "number" },
	color = { {1,1,1,1}, "color"},
	ox = { 0.5, "number", set.imgOffsetFraction, get.imgOffsetFraction },
	oy = { 0.5, "number", set.imgOffsetFraction, get.imgOffsetFraction },
	kx = { 0, "number" },
	ky = { 0, "number" }
}
M.constructArgs.Sprite = {
	{"image"}, {"pos", "x"}, {"pos", "y"}, {"angle"}, {"sx"}, {"sy"},
	{"color"}, {"ox"}, {"oy"}, {"kx"}, {"ky"},
}

M.Text = {
	-- key = { defaultVal, type, setter, getter }
	text = { "", "string"},
	font = { NO_DEFAULT, "font", set.font, get.assetParams, defAssets.font},
	pos = { {x=0,y=0}, "vector2", set.pos, get.pos },
	angle = { 0, "number" },
	wrapLimit = { nil, "number" },
	hAlign = { "left", "string" },
	sx = { 1, "number" },
	sy = { 1, "number" },
	kx = { 0, "number" },
	ky = { 0, "number" }
}
M.constructArgs.Text = {
	{"text"}, {"font"}, {"pos", "x"}, {"pos", "y"}, {"angle"},
	{"wrapLimit"}, {"hAlign"}, {"sx"}, {"sy"}, {"kx"}, {"ky"}
}

M.Quad = {
	-- key = { defaultVal, type, setter, getter }
	image = { NO_DEFAULT, "string", set.imageData, get.assetParams, defAssets.image },
	quad = { NO_DEFAULT, "quad", set.quadParams, get.quadParams, defAssets.quad },
	pos = { {x=0,y=0}, "vector2", set.pos, get.pos },
	angle = { 0, "number" },
	sx = { 1, "number" },
	sy = { 1, "number" },
	color = { {1,1,1,1}, "color"},
	ox = { 0.5, "number", set.imgOffsetFraction, get.imgOffsetFraction },
	oy = { 0.5, "number", set.imgOffsetFraction, get.imgOffsetFraction },
	kx = { 0, "number" },
	ky = { 0, "number" }
}
M.constructArgs.Quad = {
	{"image"}, {"quad"}, {"pos", "x"}, {"pos", "y"}, {"angle"}, {"sx"}, {"sy"},
	{"color"}, {"ox"}, {"oy"}, {"kx"}, {"ky"}
}

M.World = {
	-- key = { defaultVal, type, setter, getter }
	xg = { 0, "number", set.gravity, get.gravity },
	yg = { 0, "number", set.gravity, get.gravity },
	sleep = { false, "bool", set.sleepingAllowed, get.sleepingAllowed },
	disableBegin = { false, "bool", set.worldCallbackEnabled, get.worldCallbackEnabled },
	disableEnd = { false, "bool", set.worldCallbackEnabled, get.worldCallbackEnabled },
	disablePre = { false, "bool", set.worldCallbackEnabled, get.worldCallbackEnabled },
	disablePost = { false, "bool", set.worldCallbackEnabled, get.worldCallbackEnabled },
}
M.constructArgs.World = {
	{"xg"}, {"yg"}, {"sleep"}, {"disableBegin"}, {"disableEnd"}, {"disablePre"}, {"disablePost"},
}

for i,className in ipairs(M.classList) do
	local argList = M.constructArgs[className]
	local minArgs = {}
	M.minimumConstructArgs[className] = minArgs
	local foundARequiredArg = false
	for i=#argList,1,-1 do
		local key, subKey = argList[i][1], argList[i][2]
		local default, placeholder = M.getDefault(className, key, subKey)
		if foundARequiredArg then -- Need a value, put in the editor default.
			minArgs[i] = default ~= NO_DEFAULT and default or placeholder
		elseif default == NO_DEFAULT then -- First required value, put in the editor placeholder.
			foundARequiredArg = true
			minArgs[i] = placeholder
		end
	end
end

-- Property widgets:
-- 	Numeric input box.
--		String input box.
-- 	Read-only string.
--		XY-Vector input boxes.
--		4-value Color input boxes. (limit to 0-1?)
			-- Have a colorpicker eventually.
--		String arrays. (`script`)

return M
