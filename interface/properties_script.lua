
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
	local propList = classConstructorArgs[obj.className] or classConstructorArgs.Object
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
		local b = PropertyWidget(name, tostring(value))
		self.contents.h = self.contents.h + b.h
		self.contents:_updateInnerSize()
		scene:add(b, self.contents)
		self.contents:add(b)


		local inputFld = scene:get(b.path .. "/Row/input")
		local inputTxt = scene:get(b.path .. "/Row/input/text")
		self.ruu:makeInputField(inputFld, inputTxt, true)
		b.ruuWidget = inputFld
	end
	self:setMaskOnChildren()
end

function script.setProperty(self, key, val)
	if not self.obj then
		print("Properties.setProperty - No Object Set.", key, val)
		return
	end
end

return script
