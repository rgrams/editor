
local script = {}

local inputManager = require "input-manager"
local RUU = require "ruu.ruu"
local theme = require "theme.theme"

local function buttonFunc(self)
	local text = self.label.text
	self.parentMenu:call("close", text)
end

function script.close(self, itemText)
	inputManager.remove(self)
	if self.callback then
		self.callback(itemText, unpack(self.callbackArgs))
	end
	scene:remove(self)
end

function script.init(self)
	inputManager.add(self, "top", false)
	self.ruu = RUU(theme)
	local ruu = self.ruu
	local layers = { "gui debug", "popupText", "popupWidgets", "popupPanels", "text", "widgets", "panels" }
	ruu:registerLayers(layers)

	local map = {}
	for i,btn in ipairs(self.buttons) do
		ruu:makeButton(btn, true, buttonFunc)
		map[i] = {btn}
	end

	ruu:mapNeighbors(map)

	ruu:setFocus(self.buttons[1])

	local mx, my = love.mouse.getPosition()
	ruu:mouseMoved(mx, my, 0, 0)
end

local dirs = { up = "up", down = "down", left = "left", right = "right" }

function script.input(self, name, value, change)
	if name == "left click" then
		self.ruu:input("click", nil, change)
		-- Close menu if nothing is clicked on?
	elseif name == "confirm" then
		self.ruu:input("enter", nil, change)
	elseif dirs[name] then
		self.ruu:input("direction", dirs[name], change)
	elseif name == "scroll x" then
		self.ruu:input("scroll x", nil, value)
	elseif name == "scroll y" then
		self.ruu:input("scroll y", nil, value)
	elseif name == "text" then
		self.ruu:input("text", nil, value)
	elseif name == "backspace" and value == 1 then
		self.ruu:input("backspace")
	elseif name == "cancel" and change == 1 then
		self:call("close")
	end
	return true -- consume all input
end

function script.mouseMoved(self, x, y, dx, dy)
	self.ruu:mouseMoved(x, y, dx, dy)
	return true -- consume all input
end

return script