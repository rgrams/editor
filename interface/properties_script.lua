
local script = {}

local Button = require "theme.widgets.Button"
local PropertyWidget = require "theme.widgets.properties.Basic"
local activeData = require "activeData"
local classConstructorArgs = require "object.class-constructor-args"

function script.init(self)
	activeData.propertiesPanel = self
	self.contents = scene:get(self.path .. "/contents")
	self.ruu = activeData.ruu
end

local function stringtobool(v)
	if v == "false" then  return false  end
	if v == "true" then  return true  end
end

local ignoreThisKeyForNow = { image = true, quad = true, font = true, color = true }

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

local function getPropertyValue(obj, propData)
	-- { "pos", "vector2", {"x", "y"} }
	local name, valType, subKeys = unpack(propData)
	if not subKeys then
		return obj[name]
	else
		local v = {}
		for i,key in ipairs(subKeys) do
			v[key] = obj[name][key]
		end
		return v
	end
end

local function clearContents(self)
	if self.contents.children then
		for i,child in ipairs(self.contents.children) do
			scene:remove(child)
			self.contents:remove(child)
			self.ruu:destroyWidget(child.ruuWidget)
		end
		self.contents.h = 10
	end
end

function script.setObject(self, obj)
	print("Properties.setObject", obj)
	self.ruu = activeData.ruu
	self.obj = obj
	clearContents(self)
	if not obj then  return  end
	local propList = classConstructorArgs[obj.className] or classConstructorArgs.Object
	local widgetMap = {}
	for i,propData in ipairs(propList) do
		-- local val = getPropertyValue(obj, propData)
		-- local name = propData[1]
		-- local str = name .. ": "
		-- if type(val) == "table" then
			-- for k,v in pairs(val) do
				-- str = str .. k .. ":"

		local key, subKey, getter = propData[1], propData[3], propData[4]
		getter = getter or classConstructorArgs.defaultGetter
		local name = key
		if subKey then  name = name .. "." .. subKey  end
		local value = getter(obj, key, subKey)
		local node = PropertyWidget(name, tostring(value))
		self.contents.h = self.contents.h + node.h
		self.contents:_updateInnerSize()
		scene:add(node, self.contents)
		self.contents:add(node)

		local inputFld = scene:get(node.path .. "/Row/input")
		local inputTxt = scene:get(node.path .. "/Row/input/text")
		self.ruu:makeInputField(inputFld, inputTxt, true, nil, propWidgetConfirmFunc)
		node.ruuWidget = inputFld
		inputFld._propKey, inputFld._propSubKey = key, subKey
		table.insert(widgetMap, {inputFld})
	end
	self.ruu:mapNeighbors(widgetMap)
	self:setMaskOnChildren()
end

function script.setProperty(self, obj, key, val, subKey)
	if obj ~= self.obj then
		print("Properties.setProperty - Object mis-match.", obj, self.obj, key, val)
		return
	end
	local name = key
	if subKey then  name = name .. "." .. subKey  end
	local widgetPath = self.path .. "/contents/" .. name .. "/Row/input"
	local inputField = scene:get(widgetPath)
	inputField:setText(tostring(val))
end

return script
