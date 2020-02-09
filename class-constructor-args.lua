
-- Stores a list of class constructor orguments for each object class.

--    Has the information needed to get each argument from an existing
--    object, so a constructor call can be encoded to recreate that object.
--        - The argument's key name on the object.
--        - The default value of the argument.
--        - The property sub-key, if the value is in a table on the object.

local M = {}

local NO_DEFAULT = {}

local function shallowCopy(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
end

local function getAssetParams(obj, key)
	local params = new.paramsFor[obj[key]]
	assert(params, "Couldn't get parameters for asset: '" .. tostring(asset) .. "'.")
	if #params == 1 then  params = params[1]  end
	return params
end

local function getImageOffset(obj, key)
	local o = obj[key]
	local imgW, imgH = obj.image:getDimensions()
	if key == "ox" then
		return o / imgW
	else
		return o / imgH
	end
end

local function getQuadParams(obj, key)
	return obj[quad]:getViewport()
end

M.Object = {
	-- key, default value, sub-key, getterFunc
		-- sub-key is used if the argument is in a table on the object (like x and y pos).
	{"pos", 0, "x"}, {"pos", 0, "y"}, {"angle", 0},
	{"sx", 1}, {"sy", 1}, {"kx", 0}, {"ky", 0}
}

-- [[

M.Sprite = {
	{"image", NO_DEFAULT, false, getAssetParams},
	{"pos", 0, "x"}, {"pos", 0, "y"}, {"angle", 0},
	{"sx", 1}, {"sy", 1},
	{"color", 1, 1}, {"color", 1, 2}, {"color", 1, 3}, {"color", 1, 4},
	{"ox", 0.5, false, getImageOffset}, {"oy", 0.5, false, getImageOffset},
	{"kx", 0}, {"ky", 0}
}

M.Text = {
	{"text", ""},
	{"font", NO_DEFAULT, false, getAssetParams},
	{"pos", 0, "x"}, {"pos", 0, "y"}, {"angle", 0},
	{"wrapLimit"}, {"hAlign", "left"},
	{"sx", 1}, {"sy", 1}, {"kx", 0}, {"ky", 0},
}

M.Quad = {
	{"image", NO_DEFAULT, false, getAssetParams},
	{"quad", NO_DEFAULT, false, getQuadParams},
	{"pos", 0, "x"}, {"pos", 0, "y"}, {"angle", 0},
	{"sx", 1}, {"sy", 1},
	{"color", 1, 1}, {"color", 1, 2}, {"color", 1, 3}, {"color", 1, 4},
	{"ox", 0.5, false, getImageOffset}, {"oy", 0.5, false, getImageOffset},
	{"kx", 0}, {"ky", 0},
}

--]]

-- Create dictionaries of argument keys for each class, so properties on
-- an object can be quickly checked to see if they go into the constructor,
-- or if they should be added on afterward.
local keys = {}
for className,classArgs in pairs(M) do
	local classKeys = {}
	keys[className] = classKeys
	for i,argSpecs in ipairs(classArgs) do
		local argName = argSpecs[1]
		classKeys[argName] = true
	end
end
M.keys = keys

-- Possible property names to mod() onto an object.
-- If a object's property is not in M.keys or M.modKeys, then it is ignored by the encoder.
M.modKeys = {
	name = true, children = true, _script = true
}

return M
