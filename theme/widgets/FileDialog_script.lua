
local script = {}

local RUU = require "ruu.ruu"
local ruuInputHandler = require "lib.ruuInputHandler"
local theme = require "theme.theme"
local PopupConfirm = require "theme.widgets.PopupConfirm"

local function confirmOverwrite(self, wasConfirmed)
	if wasConfirmed then
		self:call("close")
	end
end

local function checkForOverwrite(self)
	local mountedPath = self.basePath..self.inputFieldText.text
	local fileExists = love.filesystem.getInfo(mountedPath)
	if fileExists then
		local popup = PopupConfirm(
			"Confirm Overwrite",
			mountedPath.." already exists.\nDo you want to replace it?",
			"yes", "no",
			confirmOverwrite, self
		)
		local root = scene:get("/root")
		scene:add(popup, root)
	end
	return fileExists
end

local function inputConfirm(self, fromUnfocus)
	if not fromUnfocus then
		local isOverwrite = checkForOverwrite(self.dialog)
		if not isOverwrite then  self.dialog:call("close")  end
	end
end

local function confirm(self)
	local isOverwrite = checkForOverwrite(self.dialog)
	if not isOverwrite then  self.dialog:call("close")  end
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

function script.fileClicked(self, fileWgt)
	self.inputFieldText.text = fileWgt.filename
end

function script.fileDoubleClicked(self, fileWgt)
	self.inputFieldText.text = fileWgt.filename
	local isOverwrite = checkForOverwrite(self)
	if not isOverwrite then  self:call("close")  end
end

function script.close(self, wasCanceled)
	Input.disable(self)
	local filename = self.inputFieldText.text
	if self.callback then
		if wasCanceled then
			self.callback(self.callbackObj, nil, nil, nil, unpack(self.callbackArgs))
		else
			self.callback(self.callbackObj, self.basePath, self.realBasePath, filename, unpack(self.callbackArgs))
		end
	end
	scene:remove(self)
end

function script.input(self, action, value, change, isRepeat, x, y, dx, dy)
	if action == "cancel" and change == 1 then
		self:call("close", true)
	else
		self.ruuInput:input(action, value, change, isRepeat, x, y, dx, dy)
	end
	return true
end

return script
