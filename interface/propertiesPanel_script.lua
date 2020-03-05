
local script = {}

local PropertyWidget = require "theme.widgets.properties.Basic"
local active = require "activeData"
local objProp = require "object.object-properties"

function script.init(self)
	active.propertiesPanel = self
	self.contents = scene:get(self.path .. "/Column/Mask/contents")
	self.scrollArea = scene:get(self.path .. "/Column/Mask")
	self.isCleared = true
	self.ruu = active.ruu
	self.propDataList = {}
end

local function stringtobool(v)
	if v == "false" then  return false  end
	if v == "true" then  return true  end
end

local ignoreThisKeyForNow = { quad = true, font = true, color = true }

local function propWidgetConfirmFunc(widget)
	local value = widget.text
	value = tonumber(value) or value
	value = stringtobool(value) or value
	value = value or widget.text
	local key, subKey = widget._propKey, widget._propSubKey
	if not ignoreThisKeyForNow[key] then
		local selection = active.selection
		local enclosureList = selection:getEnclosureList()
		active.commands:perform("setSame", enclosureList, key, value, subKey)
	end
end

local function clearContents(self)
	-- If cleared more than once in the same frame (as happens with Selection.setTo),
	-- `contents.children` will still be full of DeletedMarkers, so just track the
	-- cleared state on our own.
	if self.isCleared then  return  end
	self.oldFocusedPath = nil
	if self.contents.children then
		for i,child in ipairs(self.contents.children) do
			if child.name ~= "deletedMarker" then
				scene:remove(child)
				self.contents:remove(child)
				if child.ruuWidget.isFocused then
					self.oldFocusedPath = child.ruuWidget.path
				end
				self.ruu:destroyWidget(child.ruuWidget)
			end
		end
		self.contents.h = 10
	end
	self.isCleared = true
	self.propDataList = {}
end

-- For each selected object, get its list of properties.
-- Use constructArgs list so they're in order.
-- Check them against a master list
-- If the object does NOT have a property that IS in the master list
-- Remove that property from the master list.
--   Master list is only properties that all selected objects have.
local function getPropDataList(enclosureDict)
	local masterPropList
	for enclosure,_ in pairs(enclosureDict) do
		local obj = enclosure[1]
		local objPropList = objProp.constructArgs[obj.className]
		if not masterPropList then
			-- Init master list with all of the first object`s properties (and values).
			masterPropList = {}
			for i,v in ipairs(objPropList) do
				local val = objProp.getValue(obj, v[1], v[2])
				masterPropList[i] = { v[1], v[2], val }
			end
		else
			-- Compare master list to object for any missing properties or non-matching values.
			for i=#masterPropList,1,-1 do
				local mv = masterPropList[i]
				local mKey, mSubKey = mv[1], mv[2]
				local found = false
				for i,ov in ipairs(objPropList) do
					local oKey, oSubKey = ov[1], ov[2]
					if oKey == mKey and oSubKey == mSubKey then
						found = true
						local oVal = objProp.getValue(obj, oKey, oSubKey)
						if oVal ~= mv[3] then  mv[3] = "-multiple-"  end
						break
					end
				end
				if not found then
					table.remove(masterPropList, i)
				end
			end
		end
	end
	return masterPropList
end

local function listHasProp(list, key, subKey)
	for i,propData in ipairs(list) do
		if propData[1] == key and propData[2] == subKey then
			return i
		end
	end
end

local EMPTY = {}

local function comparePropDataLists(old, new)
	local toAdd, toRemove
	-- If old list has it and new list does not: remove
	for i,propData in ipairs(old) do
		local key, subKey, value = unpack(propData)
		if not listHasProp(new, key, subKey) then
			toRemove = toRemove or {}
			table.insert(toRemove, propData)
		end
	end
	-- If new list has it and old list does not: add
	for i,propData in ipairs(new) do
		local key, subKey, value = unpack(propData)
		if not listHasProp(old, key, subKey) then
			toAdd = toAdd or {}
			table.insert(toAdd, propData)
		end
	end
	return toAdd or EMPTY, toRemove or EMPTY
end

-- Remove a property widget by it's name. ("pos.x", "kx", "image", etc.)
local function removeChildByName(self, name)
	for i,child in ipairs(self.contents.children) do
		if child.name == name then
			scene:remove(child)
			self.contents:remove(child)
			if child.ruuWidget.isFocused then
				self.oldFocusedPath = child.ruuWidget.path
			end
			self.ruu:destroyWidget(child.ruuWidget)
			self.contents.h = (#self.contents.children - 1) * child.h + 10
			self.contents:_updateInnerSize()
			return
		end
	end
end

-- Map Ruu next/prev neighbors with all existing contents children.
local function remapChildren(self)
	local widgetMap = {}
	for i,child in ipairs(self.contents.children) do
		if child.name ~= "deletedMarker" then
			local inputFld = scene:get(child.path .. "/Row/input")
			table.insert(widgetMap, inputFld)
		end
	end
	self.ruu:mapNextPrev(widgetMap)
end

function script.updateSelection(self)
	self.ruu = active.ruu
	local selection = active.selection

	if not next(selection._) then
		clearContents(self)
		return
	end

	local newPropDataList = getPropDataList(selection._)

	local toAdd, toRemove = comparePropDataLists(self.propDataList, newPropDataList)
	for i,propData in ipairs(toRemove) do
		local key, subKey, value = unpack(propData)
		local propName = subKey and (key .. "." .. subKey) or key
		removeChildByName(self, propName)
	end
	for i,propData in ipairs(toAdd) do
		local key, subKey, value = unpack(propData)

		-- Make a PropertyWidget for each property and add it to the "contents" column.
		local propName = subKey and (key .. "." .. subKey) or key
		local superWidget = PropertyWidget(propName, tostring(value))
		self.contents.h = self.contents.h + superWidget.h
		self.contents:_updateInnerSize()
		scene:add(superWidget, self.contents)
		self.contents:add(superWidget)

		-- Make the Ruu widget.
		local inputFld = scene:get(superWidget.path .. "/Row/input")
		local inputMask = scene:get(superWidget.path .. "/Row/input/Mask")
		local inputTxt = scene:get(superWidget.path .. "/Row/input/Mask/text")
		inputTxt:updateTransform()
		local scrollToRight = propName == "image"
		self.ruu:makeInputField(inputFld, inputTxt, inputMask, true, nil, propWidgetConfirmFunc, scrollToRight)
		superWidget.ruuWidget = inputFld
		inputFld._propKey, inputFld._propSubKey = key, subKey
	end
	-- Make sure "-multiple-" values get set.
	for i,propData in ipairs(newPropDataList) do
		local key, subKey, value = unpack(propData)
		local propName = subKey and (key .. "." .. subKey) or key
		local inputFld = scene:get(self.contents.path .. "/" .. propName .. "/Row/input")
		inputFld:setText(tostring(value))
	end
	self.propDataList = newPropDataList
	remapChildren(self)
	if self.oldFocusedPath then
		self.ruu:setFocus(scene:get(self.oldFocusedPath))
	end
	self.scrollArea:setMaskOnChildren()
	self.isCleared = false
end

return script
