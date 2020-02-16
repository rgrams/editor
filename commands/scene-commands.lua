
local activeData = require "activeData"
local objProp = require "object.object-properties"
local setget = require "object.object-prop-set-getters"

-- Add
local function addObject(className, enclosure, sceneTree, lx, ly, parent)
	local class = objProp.stringToClass[className]
	local argList = objProp.constructArgs[className]
	local NO_DEFAULT = objProp.NO_DEFAULT

	local args = {}
	local foundARequiredArg = false
	-- Loop backwards from the end end until we find a required arg. (one without a default value)
	-- Ignore anything after the last required arg (to leave them at defaults).
	for i=#argList,1,-1 do
		local key, subKey = argList[i][1], argList[i][2]
		local default, placeholder = objProp.getDefault(className, key, subKey)
		if foundARequiredArg then
			args[i] = default ~= NO_DEFAULT and default or placeholder
		elseif default == NO_DEFAULT then
			foundARequiredArg = true
			args[i] = placeholder
		end
	end
	local obj = class(unpack(args))
	obj.pos.x, obj.pos.y = lx, ly
	enclosure[1], obj[PRIVATE_KEY] = obj, enclosure

	sceneTree:add(obj, parent)
	return enclosure
end

-- Remove
local function removeObject(enclosure)
	local obj = enclosure[1]
	obj.tree:remove(obj)
	return obj.className, enclosure, obj.tree, obj.pos.x, obj.pos.y, obj.parent
end

-- setPosition
local function setPosition(enclosure, x, y)
	local obj = enclosure[1]
	local oldx, oldy = obj.pos.x, obj.pos.y
	obj.pos.x, obj.pos.y = x, y
	activeData.propertiesPanel:call("setProperty", obj, "pos", x, "x")
	activeData.propertiesPanel:call("setProperty", obj, "pos", y, "y")
	return enclosure, oldx, oldy
end

local function setWorldPosition(enclosure, wx, wy)
	local obj = enclosure[1]
	local oldx, oldy = obj.pos.x, obj.pos.y
	local lx, ly = obj.parent:toLocal(wx, wy)
	obj.pos.x, obj.pos.y = lx, ly
	activeData.propertiesPanel:call("setProperty", obj, "pos", lx, "x")
	activeData.propertiesPanel:call("setProperty", obj, "pos", ly, "y")
	return enclosure, oldx, oldy
end

-- setRotation?
-- setScale?

-- setProperty
local function setProperty(enclosure, key, value, subKey)
	local obj = enclosure[1]
	local propData = objProp.getSpecs(obj.className, key)
	local setter = propData[3] or setget.set.default
	local getter = propData[4] or setget.get.default
	local oldVal = getter(obj, key, subKey)
	setter(obj, key, value, subKey)
	return enclosure, key, oldVal, subKey
end

return {
	addObject = { addObject, removeObject },
	removeObject = { removeObject, addObject },
	setPosition = { setPosition, setPosition },
	setWorldPosition = { setWorldPosition, setPosition },
	setProperty = { setProperty, setProperty }
}
