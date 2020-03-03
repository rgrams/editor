
local script = {}

local RUU = require "ruu.ruu"
local ruuInputHandler = require "lib.ruuInputHandler"
local theme = require "theme.theme"

local function inputConfirm(self, fromUnfocus)
	if not fromUnfocus then
		print("Close File Dialog - "..self.text)
		self.dialog:call("close")
	end
end

local function confirm(self, fromUnfocus)
	self.dialog:call("close")
end

local function cancel(self)
	self.dialog:call("close", true)
end

function script.init(self)
	Input.enable(self, "top")
	self.ruu = RUU(Input.get, theme)
	self.ruuInput = ruuInputHandler(self.ruu)

	local layers = { "gui debug", "popupText", "popupWidgets", "popupPanels", "text", "widgets", "panels" }
	self.ruu:registerLayers(layers)

	self.ruu:makePanel(self, true)

	local filesBox = scene:get(self.path .. "/Column/Mask")
	self.ruu:makeScrollArea(filesBox, true)
	self.showSingleFolder = true

	local confirmButton = scene:get(self.path .. "/confirmButton")
	local cancelButton = scene:get(self.path .. "/cancelButton")
	confirmButton.dialog, cancelButton.dialog = self, self
	self.ruu:makeButton(confirmButton, true, confirm)
	self.ruu:makeButton(cancelButton, true, cancel)

	local inputField = scene:get(self.path .. "/Column/InputField")
	local inputMask = scene:get(self.path .. "/Column/InputField/Mask")
	local inputText = scene:get(self.path .. "/Column/InputField/Mask/Text")
	self.ruu:makeInputField(inputField, inputText, inputMask, true, nil, inputConfirm)
	inputField.dialog = self
	self.inputFieldText = inputText

	self.basePathLabel = scene:get(self.path .. "/Column/basePath")

	local mx, my = love.mouse.getPosition()
	self.ruu:mouseMoved(mx, my, 0, 0)

	self:call("setFolder", self.basePath)

	self.ruu:setFocus(inputField)
end

function script.close(self, wasCanceled)
	Input.disable(self)
	local text = self.inputFieldText.text
	if wasCanceled then  print("  Canceled.")
	else	print("  "..self.realBasePath..text)  end
	if self.callback then
		if wasCanceled then  self.callback()
		else  self.callback(self.basePath..text, self.realBasePath..text)  end
	end
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
