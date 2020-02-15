
local activeData = require "activeData"

-- Add
local objClasses = {
	Object = Object, Sprite = Sprite, Quad = Quad, Text = Text, World = World
}
local classConstructorArgs = require "object.class-constructor-args"
local objProps = require "object.editable-object-properties"
local setget = require "object.object-prop-set-getters"

local function addObject(objClassName, enclosure, sceneTree, lx, ly, parent)
	local class = objClasses[objClassName]
	local argList = classConstructorArgs[objClassName]
	local NO_DEFAULT = classConstructorArgs.NO_DEFAULT

	local args = {}
	local foundARequiredArg = false
	for i=#argList,1,-1 do -- Loop from end until we find a required arg (one without a default value).
		local argData = argList[i]
		if foundARequiredArg then
			local default, requiredPlaceholder = argData[2], argData[5]
			args[i] = default ~= NO_DEFAULT and default or requiredPlaceholder
		elseif argData[2] == NO_DEFAULT then
			foundARequiredArg = true
			args[i] = argData[5] -- Placeholder value for required arg.
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
	local propData = objProps.getSpecs(obj.className, key)
	local setter = propData[4] or setget.set.default
	local getter = propData[5] or setget.get.default
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
