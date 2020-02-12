
-- Stores a list of class constructor orguments for each object class.

--    Has the information needed to get each argument from an existing
--    object, so a constructor call can be encoded to recreate that object.
--        - The argument's key name on the object.
--        - The default value of the argument.
--        - The property sub-key, if the value is in a table on the object.

local M = {}

local NO_DEFAULT = {}
local defaultAssets = require "defaultAssets.list"

local function shallowCopy(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
end

M.Object = {
	-- key, default value, sub-key, getterFunc
		-- sub-key is used if the argument is in a table on the object (like x and y pos).
	{"pos", 0, "x"}, {"pos", 0, "y"}, {"angle", 0},
	{"sx", 1}, {"sy", 1}, {"kx", 0}, {"ky", 0}
}

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

M.Sprite = {
	{"image", NO_DEFAULT, false, getAssetParams, defaultAssets.image},
	{"pos", 0, "x"}, {"pos", 0, "y"}, {"angle", 0},
	{"sx", 1}, {"sy", 1},
	{"color", 1, 1}, {"color", 1, 2}, {"color", 1, 3}, {"color", 1, 4},
	{"ox", 0.5, false, getImageOffset}, {"oy", 0.5, false, getImageOffset},
	{"kx", 0}, {"ky", 0}
}

M.Text = {
	{"text", ""},
	{"font", NO_DEFAULT, false, getAssetParams, defaultAssets.font},
	{"pos", 0, "x"}, {"pos", 0, "y"}, {"angle", 0},
	{"wrapLimit"}, {"hAlign", "left"},
	{"sx", 1}, {"sy", 1}, {"kx", 0}, {"ky", 0},
}

local function getQuadParams(obj, key)
	return obj[quad]:getViewport()
end

M.Quad = {
	{"image", NO_DEFAULT, false, getAssetParams, defaultAssets.image},
	{"quad", NO_DEFAULT, false, getQuadParams, defaultAssets.quad},
	{"pos", 0, "x"}, {"pos", 0, "y"}, {"angle", 0},
	{"sx", 1}, {"sy", 1},
	{"color", 1, 1}, {"color", 1, 2}, {"color", 1, 3}, {"color", 1, 4},
	{"ox", 0.5, false, getImageOffset}, {"oy", 0.5, false, getImageOffset},
	{"kx", 0}, {"ky", 0},
}

local function getGravity(obj, key)
	local x, y = obj.world:getGravity()
	if key == "xg" then  return x
	else  return y  end
end

local function getIsSleepingAllowed(obj, key)
	return obj.world:isSleepingAllowed()
end

local function getWorldCallback(obj, key)
	local beginContact, endContact, preSolve, postSolve = obj.world:getCallbacks()
	if key == "disableBegin" then  return beginContact == nil
	elseif key == "disableEnd" then  return endContact == nil
	elseif key == "disablePre" then  return preSolve == nil
	elseif key == "disablePost" then  return postSolve == nil
	end
end

M.World = {
	{"xg", 0, false, getGravity}, {"yg", 0, false, getGravity},
	{"sleep", false, false, getIsSleepingAllowed},
	{"disableBegin", false, false, getWorldCallback},
	{"disableEnd", false, false, getWorldCallback},
	{"disablePre", false, false, getWorldCallback},
	{"disablePost", false, false, getWorldCallback},
}

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
M.NO_DEFAULT = NO_DEFAULT

return M
