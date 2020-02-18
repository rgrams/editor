
local activeData = require "activeData"
local objProp = require "object.object-properties"
local setget = require "object.object-prop-set-getters"

-- Add
local function addObject(className, enclosure, sceneTree, parent, modProps)
	local class = objProp.stringToClass[className]
	local argList = objProp.constructArgs[className]
	local NO_DEFAULT = objProp.NO_DEFAULT

	-- Create an instance of the class with the minimum required arguments.
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
	enclosure[1], obj[PRIVATE_KEY] = obj, enclosure

	local classPropDict = objProp[className] or objProp.object
	for k,v in pairs(modProps) do
		if classPropDict[k] then
			objProp.setValue(obj, k, v)
		end
	end

	sceneTree:add(obj, parent)
	return enclosure
end

-- Remove
local function removeObject(enclosure)
	local obj = enclosure[1]

	-- Make a dictionary of any modified properties on the object.
	local modProps = {}
	local classPropDict = objProp[obj.className] or objProp.Object
	for propName,data in pairs(classPropDict) do
		local curVal = objProp.getValue(obj, propName)
		local defaultVal = objProp.getDefault(obj.className, propName)
		if not objProp.areValuesEqual(curVal, defaultVal) then
			modProps[propName] = curVal
		end
	end
	local parent = obj.parent -- Save parent before SceneTree nullifies it.
	obj.tree:remove(obj)
	return obj.className, enclosure, obj.tree, parent, modProps
end

local function addMultiple(data)
	local enclosureList = {}
	for i,v in ipairs(data) do
		local enclosure = addObject(unpack(v))
		table.insert(enclosureList, enclosure)
	end
	return enclosureList
end

local function removeMultiple(enclosureList)
	local data = {}
	for i,enclosure in ipairs(enclosureList) do
		local args = {removeObject(enclosure)}
		table.insert(data, args)
	end
	return data
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

-- setProperty -- Only used by Properties panel.
local function setProperty(enclosure, key, value, subKey)
	local obj = enclosure[1]
	local oldVal = objProp.getValue(obj, key, subKey)
	objProp.setValue(obj, key, value, subKey)
	return enclosure, key, oldVal, subKey
end

-- Only for undo-ing `set`. Returns no args.
-- Takes a dictionary
-- objects as keys, values a table: { {key, val, subKey}, {key,val,subKey}, ... }
local function setSeparate(data)
	for enclosure,argList in pairs(data) do
		local obj = enclosure[1]
		for _,argData in ipairs(argList) do
			local key, val, subKey = unpack(argData)
			objProp.setValue(obj, key, val, subKey)
		end
	end
end

-- Set any number of properties to fixed values on any number of objects.
-- Takes a list of objects enclosures, and any number of key,value,subkey triplet arguments.
-- Returns a big data table with all the old property values for each object.
local function set(enclosureList, ...)
	local argList = {...} -- `nil` subKeys must be `false` instead!
	local propCount = math.ceil(#argList/3) -- round up so you only need to give key,val for the final set.
	-- Use global NIL for setting nil values. (for layer, script, etc.?)
	-- subKeys could be false instead, either works.
	for i,v in ipairs(argList) do
		if v == NIL then  argList[i] = nil  end
	end

	-- Convert list of all args into a table of argDatas for each property. { {key,val,subKey},... }
	local propertySettings = {}
	for pi=0,propCount-1 do
		local i = pi * 3
		local argData = { argList[i+1], argList[i+2], argList[i+3] }
		propertySettings[pi + 1] = argData
	end

	-- Set properties on each object and save all the old values & keys.
	local oldData = {}
	for i,enclosure in ipairs(enclosureList) do
		local obj = enclosure[1]
		oldData[enclosure] = {}
		for i,argData in ipairs(propertySettings) do
			local key, val, subKey = unpack(argData)
			local oldVal = objProp.getValue(obj, key, subKey)
			objProp.setValue(obj, key, val, subKey)

			-- TODO: Kinda wrong. The command might not be done on selected objects. (send this anyway?)
			activeData.propertiesPanel:call("setProperty", obj, key, val, subKey)

			local oldArgData = { key, oldVal, subKey }
			table.insert(oldData[enclosure], oldArgData)
		end
	end
	return oldData
end

return {
	addObject = { addObject, removeObject },
	removeObject = { removeObject, addObject },
	addMultiple = { addMultiple, removeMultiple },
	removeMultiple = { removeMultiple, addMultiple },
	setPosition = { setPosition, setPosition },
	setWorldPosition = { setWorldPosition, setPosition },
	setProperty = { setProperty, setProperty },
	set = { set, setSeparate }
}
