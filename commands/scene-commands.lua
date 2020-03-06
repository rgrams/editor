
local activeData = require "activeData"
local objProp = require "object.object-properties"
local setget = require "object.object-prop-set-getters"

local selectionCommands = require "commands.selection-commands"
local selectionAdd = selectionCommands.addToSelection[1]
local selectionRemove = selectionCommands.addToSelection[2]
local selectionClear = selectionCommands.clearSelection[1]
local selection_set = selectionCommands.clearSelection[2]

local function addObject(className, enclosure, sceneTree, parentEnclosure, modProps, children, wasSelected)
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

	if wasSelected then  selectionAdd(activeData.selection, enclosure)  end

	if children then
		for i,v in ipairs(children) do  addObject(unpack(v))  end
	end

	activeData.propertiesPanel:call("updateSelection")
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

local function getIsSelected(enclosure)
	return activeData.selection._[enclosure]
end

-- Recursively make a sequence of sequences of `addObject` args.
local function getChildrenReCreationData(objects)
	if not objects then  return false  end
	local t = false
	for i,obj in ipairs(objects) do
		if obj.name ~= "deletedMarker" then
			t = t or {}
			local modProps = getModifiedProperties(obj)
			local enclosure, parentEnclosure = obj[PRIVATE_KEY], obj.parent[PRIVATE_KEY]
			local children = getChildrenReCreationData(obj.children)
			local wasSelected = getIsSelected(enclosure)

			if wasSelected then  selectionRemove(activeData.selection, enclosure)  end

			local args = {obj.className, enclosure, obj.tree, parentEnclosure, modProps, children, wasSelected}
			table.insert(t, args)
		end
	end
	return t
end

-- For objects with children, save a list of `addObject` args for each child.
	-- ({className, enclosure, sceneTree, parentEnclosure, modProps, children, wasSelected})
local function removeObject(enclosure)
	local obj = enclosure[1]
	local modProps = getModifiedProperties(obj)
	local children = getChildrenReCreationData(obj.children)
	local wasSelected = getIsSelected(enclosure)
	if wasSelected then  selectionRemove(activeData.selection, enclosure)  end
	local parentEnclosure = obj.parent[PRIVATE_KEY] or false -- Save parent before SceneTree nullifies it.
	obj.tree:remove(obj)
	activeData.propertiesPanel:call("updateSelection")
	return obj.className, enclosure, obj.tree, parentEnclosure, modProps, children, wasSelected
end

-- Takes a sequence of sequences of `addObject` args:
	-- {className, enclosure, sceneTree, parentEnclosure, modProps, children, wasSelected}
local function addMultiple(data)
	local enclosureList = {}
	for i,v in ipairs(data) do
		local enclosure = addObject(unpack(v))
		table.insert(enclosureList, enclosure)
	end
	activeData.propertiesPanel:call("updateSelection")
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

-- Removes objects from the list if any of their ancestors are also in the list.
local function cleanDescendantsFromList(enclosureList)
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
end

local function removeMultiple(enclosureList)
	local undoData = {}
	-- Remove objects from the list if any of their ancestors is also being removed.
	--   That way there's no duplication on undo, and they are recreated in parent-child order. (as they need to be)
	cleanDescendantsFromList(enclosureList)

	for i,enclosure in ipairs(enclosureList) do
		local args = {removeObject(enclosure)}
		table.insert(undoData, args)
	end
	activeData.propertiesPanel:call("updateSelection")
	return undoData -- A sequence of sequences of `addObject` args.
end

-- Clears the selection in one go so we can undo and recover the selection history.
--   Don't call if there's nothing in the selection, or you'll have a command
--   in the undo history that does nothing.
local function removeAllSelected(selection)
	local enclosureList = selection:getEnclosureList()
	local _, oldList, oldHistory = selectionClear(selection)
	local undoRemoveData = removeMultiple(enclosureList)
	activeData.propertiesPanel:call("updateSelection")
	return undoRemoveData, selection, oldList, oldHistory
end

local function undoRemoveAllSelected(undoRemoveData, selection, oldList, oldHistory)
	addMultiple(undoRemoveData)
	selection_set(selection, oldList, oldHistory)
end

local function copySelection(selection)
	local enclosureList = selection:getEnclosureList()
	local oldClipboard = activeData.clipboard
	cleanDescendantsFromList(enclosureList)
	local data = {}
	for i,enclosure in ipairs(enclosureList) do
		local obj = enclosure[1]
		-- NOTE: object and parent enclosures for obj and all descendants will need to be changed on paste.
		local args = {
			obj.className, false,
			obj.tree, false,
			getModifiedProperties(obj),
			getChildrenReCreationData(obj.children)
		}
		table.insert(data, args)
	end
	activeData.clipboard = data
	return oldClipboard or data -- No reason to undo clipboard to `nil`.
end

local function undoCopy(data)
	activeData.clipboard = data
end

local function cutSelection(selection)
	local enclosureList = selection:getEnclosureList()
	local oldClipboard = copySelection(selection) -- Ignores selection info, as opposed to `undoRemoveData`.
	local undoRemoveData, selection, oldList, oldHistory = removeAllSelected(selection)
	return oldClipboard, undoRemoveData, selection, oldList, oldHistory
end

local function undoCutSelection(oldClipboard, undoRemoveData, selection, oldList, oldHistory)
	undoRemoveAllSelected(undoRemoveData, selection, oldList, oldHistory)
	activeData.clipboard = oldClipboard
end

-- Takes the `addObject` argument data for one object and its descendants.
-- Recursively makes new obj enclosures, updates parent enclosure refs, and
-- sets the current SceneTree.
local function updateDataForPaste(addDataList, parentEnclosure, tree)
	for i,addData in ipairs(addDataList) do
		addData[2] = {} -- Make new enclosure.
		addData[3] = tree
		addData[4] = parentEnclosure
		if addData[6] then -- Has children
			updateDataForPaste(addData[6], addData[2], tree)
		end
	end
end

local function pasteOntoSelection(selection)
	local clipboard = activeData.clipboard
	local enclosureList = selection:getEnclosureList()
	local undoData
	if #enclosureList == 0 then -- Nothing selected, add to SceneTree (no parent).
		updateDataForPaste(clipboard, false, activeData.scene)
		undoData = addMultiple(clipboard)
	else
		undoData = {}
		for i,parentEnclosure in ipairs(enclosureList) do
			updateDataForPaste(clipboard, parentEnclosure, activeData.scene)
			local data = addMultiple(clipboard)
			for i,v in ipairs(data) do
				table.insert(undoData, v)
			end
		end
	end
	return undoData
end

-- setProperty -- Only used by Properties panel.
local function setProperty(enclosure, key, value, subKey)
	local obj = enclosure[1]
	local oldVal = objProp.getValue(obj, key, subKey)
	objProp.setValue(obj, key, value, subKey)
	activeData.propertiesPanel:call("updateSelection")
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
	activeData.propertiesPanel:call("updateSelection")
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
	activeData.propertiesPanel:call("updateSelection")
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
	activeData.propertiesPanel:call("updateSelection")
	return undoData
end

return {
	addObject = { addObject, removeObject },
	removeObject = { removeObject, addObject },
	addMultiple = { addMultiple, removeMultiple },
	removeMultiple = { removeMultiple, addMultiple },
	removeAllSelected = { removeAllSelected, undoRemoveAllSelected },
	setProperty = { setProperty, setProperty },
	setSeparate = { setSeparate, setSeparate },
	setSame = { setSame, setSeparate },
	setSameMultiple = { setSameMultiple, setSeparate },
	copySelection = { copySelection, undoCopy },
	cutSelection = { cutSelection, undoCutSelection },
	pasteOntoSelection = { pasteOntoSelection, removeMultiple }
}
