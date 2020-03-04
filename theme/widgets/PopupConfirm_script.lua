
local script = {}

local RUU = require "ruu.ruu"
local ruuInputHandler = require "lib.ruuInputHandler"
local theme = require "theme.theme"

local function confirmBtnPressed(self)
	self.dialog:call("close", true)
end

local function cancelBtnPressed(self)
	self.dialog:call("close", false)
end

function script.init(self)
	Input.enable(self, "top")
	self.ruu = RUU(Input.get, theme)
	self.ruuInput = ruuInputHandler(self.ruu)

	local layers = { "gui debug", "popupText", "popupWidgets", "popupPanels", "text", "widgets", "panels" }
	self.ruu:registerLayers(layers)

	self.ruu:makePanel(self, true)

	local confirmButton = scene:get(self.path .. "/Column/btnParent/confirmButton")
	local cancelButton = scene:get(self.path .. "/Column/btnParent/cancelButton")
	confirmButton.dialog, cancelButton.dialog = self, self
	self.ruu:makeButton(confirmButton, true, confirmBtnPressed)
	self.ruu:makeButton(cancelButton, true, cancelBtnPressed)

	local mx, my = love.mouse.getPosition()
	self.ruu:mouseMoved(mx, my, 0, 0)

	self.ruu:setFocus(cancelButton)
end

function script.close(self, wasConfirmed)
	Input.disable(self)
	scene:remove(self)
	if self.callback then
		self.callback(self.callbackObj, wasConfirmed)
	end
end

function script.input(self, action, value, change, isRepeat, x, y, dx, dy)
	if action == "cancel" and change == 1 then
		self:call("close", false)
	else
		self.ruuInput:input(action, value, change, isRepeat, x, y, dx, dy)
	end
	return true
end

return script
