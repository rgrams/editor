
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
end

function script.updateSelection(self)
	self.ruu = active.ruu
	local selection = active.selection
	clearContents(self)

	if not next(selection._) then
		return
	end

	-- For each selected object, get its list of properties.
		-- Use constructArgs list so they're in order.
	-- Check them against a master list
		-- If the object does NOT have a property that IS in the master list
			-- Remove that property from the master list.
	local masterPropList

	for enclosure,_ in pairs(selection._) do
		local obj = enclosure[1]
		local objPropList = objProp.constructArgs[obj.className]
		if not masterPropList then
			masterPropList = {}
			for i,v in ipairs(objPropList) do
				local val = objProp.getValue(obj, v[1], v[2])
				masterPropList[i] = { v[1], v[2], val }
			end
		else
			for i=#masterPropList,1,-1 do
				local v = masterPropList[i]
				local mKey, mSubKey = v[1], v[2]
				local found = false
				for i,v2 in ipairs(objPropList) do
					local oKey, oSubKey = v2[1], v2[2]
					if oKey == mKey and oSubKey == mSubKey then
						found = true
						local oVal = objProp.getValue(obj, oKey, oSubKey)
						if oVal ~= v[3] then  v[3] = "-multiple-"  end
						break
					end
				end
				if not found then
					table.remove(masterPropList, i)
				end
			end
		end
	end

	local widgetMap = {}
	for i,propData in ipairs(masterPropList) do
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
		table.insert(widgetMap, inputFld)
	end
	self.ruu:mapNextPrev(widgetMap)
	if self.oldFocusedPath then
		self.ruu:setFocus(scene:get(self.oldFocusedPath))
	end
	self.scrollArea:setMaskOnChildren()
	self.isCleared = false
end

return script
