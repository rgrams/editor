
local script = {}

local RUU = require "ruu.ruu"
local ruuInputHandler = require "lib.ruuInputHandler"
local theme = require "theme.theme"

local function confirm(self)
	self.dialog:call("close")
end

local function cancel(self)
	self.dialog:call("close")
end

function script.init(self)
	Input.enable(self, "top")
	self.ruu = RUU(Input.get, theme)
	self.ruuInput = ruuInputHandler(self.ruu)

	local layers = { "gui debug", "popupText", "popupWidgets", "popupPanels", "text", "widgets", "panels" }
	self.ruu:registerLayers(layers)

	self.ruu:makePanel(self, true)

	self.filesBox = scene:get(self.path .. "/Column/Mask")
	self.ruu:makeScrollArea(self.filesBox, true)
	self.filesBox.ruu = self.ruu
	self.filesBox.showSingleFolder = true

	local confirmButton = scene:get(self.path .. "/confirmButton")
	local cancelButton = scene:get(self.path .. "/cancelButton")
	confirmButton.dialog, cancelButton.dialog = self, self
	self.ruu:makeButton(confirmButton, true, confirm)
	self.ruu:makeButton(cancelButton, true, cancel)

	self.basePathLabel = scene:get(self.path .. "/Column/basePath")

	local mx, my = love.mouse.getPosition()
	self.ruu:mouseMoved(mx, my, 0, 0)

	self.filesBox:call("setFolder", self.basePath)
end

function script.close(self, itemText)
	Input.disable(self)
	-- if self.callback then
		-- self.callback(itemText, unpack(self.callbackArgs))
	-- end
	scene:remove(self)
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
