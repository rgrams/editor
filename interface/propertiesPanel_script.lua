
local script = {}

local PropertyWidget = require "theme.widgets.properties.Basic"
local activeData = require "activeData"
local objProp = require "object.object-properties"

function script.init(self)
	activeData.propertiesPanel = self
	self.contents = scene:get(self.path .. "/contents")
	self.isCleared = true
	self.ruu = activeData.ruu
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
		local selection = activeData.selection._
		local obj = next(selection)
		activeData.commands:perform("setProperty", obj[PRIVATE_KEY], key, value, subKey)
	end
end

local function clearContents(self)
	-- If cleared more than once in the same frame (as happens with Selection.setTo),
	-- `contents.children` will still be full of DeletedMarkers, so just track the
	-- cleared state on our own.
	if self.isCleared then  return  end
	if self.contents.children then
		for i,child in ipairs(self.contents.children) do
			scene:remove(child)
			self.contents:remove(child)
			self.ruu:destroyWidget(child.ruuWidget)
		end
		self.contents.h = 10
	end
	self.isCleared = true
end

function script.updateSelection(self, objDict)
	print("--  PropertiesPanel.updateSelection  --")
	self.ruu = activeData.ruu
	clearContents(self)
	if not next(objDict) then
		print("  No objects selected.")
		return
	end

	local obj = next(objDict)
	print("  Object Selected: " .. tostring(obj.path))

	local widgetMap = {}
	local constructArgs = objProp.constructArgs[obj.className] or objProp.constructArgs.Object
	local argDataDict = objProp[obj.className] or objProp.Object
	for i,propKeys in ipairs(constructArgs) do
		-- Get the property value from the object.
		local key, subKey = propKeys[1], propKeys[2]
		local value = objProp.getValue(obj, key, subKey)

		-- Make a PropertyWidget for each property and add it to the "contents" column.
		local nodeName = subKey and (key .. "." .. subKey) or key
		local node = PropertyWidget(nodeName, tostring(value))
		self.contents.h = self.contents.h + node.h
		self.contents:_updateInnerSize()
		scene:add(node, self.contents)
		self.contents:add(node)

		-- Make the Ruu widget.
		local inputFld = scene:get(node.path .. "/Row/input")
		local inputTxt = scene:get(node.path .. "/Row/input/text")
		self.ruu:makeInputField(inputFld, inputTxt, true, nil, propWidgetConfirmFunc)
		node.ruuWidget = inputFld
		inputFld._propKey, inputFld._propSubKey = key, subKey
		table.insert(widgetMap, {inputFld})
	end
	self.ruu:mapNeighbors(widgetMap)
	self:setMaskOnChildren()
	self.isCleared = false
end

function script.setProperty(self, obj, key, val, subKey)
	local name = key
	if subKey then  name = name .. "." .. subKey  end
	local widgetPath = self.path .. "/contents/" .. name .. "/Row/input"
	local inputField = scene:get(widgetPath)
	inputField:setText(tostring(val))
end

return script
