
local activeData = require "activeData"
local objProp = require "object.object-properties"
local setget = require "object.object-prop-set-getters"

local function addObject(className, enclosure, sceneTree, parentEnclosure, modProps, children)
	local class = objProp.stringToClass[className]
	local argList = objProp.constructArgs[className]
	local NO_DEFAULT = objProp.NO_DEFAULT

	-- Create an instance of the class with the minimum required arguments.
	local args = objProp.minimumConstructArgs[className]
	local obj = class(unpack(args))
	enclosure[1], obj[PRIVATE_KEY] = obj, enclosure

	-- Mod on changed properties, if any.
	local classPropDict = objProp[className] or objProp.object
	if modProps then
		for k,v in pairs(modProps) do
			if classPropDict[k] then  objProp.setValue(obj, k, v)  end
		end
	end
	sceneTree:add(obj, parentEnclosure and parentEnclosure[1])

	if children then
		for i,v in ipairs(children) do  addObject(unpack(v))  end
	end

	return enclosure
end

local function getModifiedProperties(obj)
	local modProps
	local classPropDict = objProp[obj.className] or objProp.Object
	for propName,data in pairs(classPropDict) do
		local curVal = objProp.getValue(obj, propName)
		local defaultVal = objProp.getDefault(obj.className, propName)
		if not objProp.areValuesEqual(curVal, defaultVal) then
			modProps = modProps or {}
			modProps[propName] = curVal
		end
	end
	return modProps
end

-- Recursively make a sequence of sequences of `addObject` args.
local function getChildrenReCreationData(objects)
	if not objects then  return  end
	local t
	for i,obj in ipairs(objects) do
		if obj.name ~= "deletedMarker" then
			t = t or {}
			local modProps = getModifiedProperties(obj)
			local enclosure, parentEnclosure = obj[PRIVATE_KEY], obj.parent[PRIVATE_KEY]
			local args = {obj.className, enclosure, obj.tree, parentEnclosure, modProps}
			if obj.children then
				args[6] = getChildrenReCreationData(obj.children)
			end
			table.insert(t, args)
		end
	end
	return t
end

-- For objects with children, save a list of `addObject` args for each child.
	-- ({className, enclosure, sceneTree, parentEnclosure, modProps, children})
local function removeObject(enclosure)
	local obj = enclosure[1]
	local modProps = getModifiedProperties(obj)
	local children = getChildrenReCreationData(obj.children)
	local parentEnclosure = obj.parent[PRIVATE_KEY] -- Save parent before SceneTree nullifies it.
	obj.tree:remove(obj)
	return obj.className, enclosure, obj.tree, parentEnclosure, modProps, children
end

-- Takes a sequence of sequences of `addObject` args: {className, enclosure, sceneTree, parent, modProps}
local function addMultiple(data)
	local enclosureList = {}
	for i,v in ipairs(data) do
		local enclosure = addObject(unpack(v))
		table.insert(enclosureList, enclosure)
	end
	return enclosureList -- A sequence of object enclosures.
end

local function dictContainsAncestor(dict, obj)
	local p = obj.parent
	while not dict[p] do
		p = p.parent
		if not p then  return false  end
	end
	return true
end

local function removeMultiple(enclosureList)
	local undoData = {}

	-- Remove objects from the list if any of their ancestors is also being removed.
	--   That way there's no duplication on undo, and they are recreated in parent-child order. (as they need to be)
	local objDict = {} -- Make a dict of the objects to remove for quick checking.
	for i,enclosure in ipairs(enclosureList) do
		objDict[enclosure[1]] = true
	end
	for i=#enclosureList,1,-1 do
		local obj = enclosureList[i][1]
		if dictContainsAncestor(objDict, obj) then
			table.remove(enclosureList, i)
		end
	end
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
