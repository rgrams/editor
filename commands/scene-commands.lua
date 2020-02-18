
local activeData = require "activeData"
local objProp = require "object.object-properties"
local setget = require "object.object-prop-set-getters"

local function addObject(className, enclosure, sceneTree, parent, modProps)
	assert(parent, "Command: 'addObject' - No parent specified.")
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
	if modProps then
		for k,v in pairs(modProps) do
			if classPropDict[k] then  objProp.setValue(obj, k, v)  end
		end
	end

	sceneTree:add(obj, parent)
	return enclosure
end

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
	return enclosureList -- A sequence of object enclosures.
end

local function removeMultiple(enclosureList)
	local undoData = {}
	for i,enclosure in ipairs(enclosureList) do
		local args = {removeObject(enclosure)}
		table.insert(undoData, args)
	end
	return undoData -- A sequence of sequences of `addObject` args.
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

-- setProperty -- Only used by Properties panel.
local function setProperty(enclosure, key, value, subKey)
	local obj = enclosure[1]
	local oldVal = objProp.getValue(obj, key, subKey)
	objProp.setValue(obj, key, value, subKey)
	return enclosure, key, oldVal, subKey
end

-- Set different properties (or just different values) on each object in a list of objects.
-- Takes a sequence of sequences of `setProperty` args (and returns one).
local function setSeparate(data)
	local undoData = {}
	for i,v in ipairs(data) do
		local args = {setProperty(unpack(v))}
		table.insert(undoData, args)
	end
	return undoData
end

-- Set a property to the same value on any number of objects.
-- Returns a sequence of sequences of `setProperty` args.
local function setSame(enclosureList, key, val, subKey)
	local undoData = {}
	for i,enclosure in ipairs(enclosureList) do
		local args = {setProperty(enclosure, key, val, subKey)}
		table.insert(undoData, args)
	end
	return undoData
end

-- Set multiple properties (each with its own value) equally on any number of objects.
-- Returns a sequence of sequences of `setProperty` args.
-- NOTE: Can't use `nil`, for values or subKeys, must use the global var `NIL` instead.
local function setSameMultiple(enclosureList, ...)
	local argList = {...}
	local propCount = math.ceil(#argList/3) -- Round up so you only need to give key,val for the final set.
	for i,v in ipairs(argList) do
		if v == NIL then  argList[i] = nil  end
	end

	for pI=0,propCount-1 do
		local i = pI*3
		local key, val, subKey = argList[i+1], argList[i+2], argList[i+3]
		for _,enclosure in ipairs(enclosureList) do
			local args = {setProperty(enclosure, key, val, subKey)}
			table.insert(undoData, args) -- Added for each property for each object.
		end
	end
	return undoData
end

return {
	addObject = { addObject, removeObject },
	removeObject = { removeObject, addObject },
	addMultiple = { addMultiple, removeMultiple },
	removeMultiple = { removeMultiple, addMultiple },
	setPosition = { setPosition, setPosition },
	setWorldPosition = { setWorldPosition, setPosition },
	setProperty = { setProperty, setProperty },
	setSeparate = { setSeparate, setSeparate },
	setSame = { setSame, setSeparate },
	setSameMultiple = { setSameMultiple, setSeparate }
}
