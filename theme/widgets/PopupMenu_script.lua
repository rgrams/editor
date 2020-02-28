
local script = {}

local RUU = require "ruu.ruu"
local ruuInputHandler = require "lib.ruuInputHandler"
local theme = require "theme.theme"

local function buttonFunc(self)
	local text = self.label.text
	self.parentMenu:call("close", text)
end

function script.close(self, itemText)
	Input.disable(self)
	if self.callback then
		self.callback(itemText, unpack(self.callbackArgs))
	end
	scene:remove(self)
end

function script.init(self)
	Input.enable(self, "top")
	self.ruu = RUU(theme)
	self.ruuInput = ruuInputHandler(self.ruu)
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

function script.input(self, action, value, change, isRepeat, x, y, dx, dy)
	if action == "cancel" and change == 1 then
		self:call("close")
	else
		self.ruuInput:input(action, value, change, isRepeat, x, y, dx, dy)
	end
	return true
end

return script
