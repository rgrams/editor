
local fonts = require "theme.fonts"
local Panel = require "theme.widgets.Panel"
local Button = require "theme.widgets.PopupButton"
local InputField = require "theme.widgets.InputField"
local dialogScript = require "theme.widgets.FileDialog_script"
local fileBrowser = require "interface.FileBrowser_script"

local function new(basePath, btnText, callback, callbackObj, ...)
	local self = mod(Panel(0, 0, 0, 700, 500, 0, 0, 0, 0, "fit", nil, 16), {name = "FileDialog", layer = "popupPanels", script = {fileBrowser, dialogScript}, children = {
		mod(gui.Column(6, nil, {{1},{2},{3,nil,true},{4}}, 0, 0, 0, 670, 400, 0, -1, 0, -1, {"stretch", "fit"}), {children = {
			mod(gui.Text(btnText, fonts.panelTitle, 30, 0, 0, 700, -1, 0, -1, 0), {layer = "popupText", name = "title"}),
			mod(gui.Text(basePath, fonts.default, 10, 0, 0, 700, -1, 0, -1, 0), {layer = "popupText", name = "basePath"}),
			mod(gui.Mask(), {resizeModeX = "fill", resizeModeY = "fill", children = {
				mod(gui.Column(), {py = -1, ay = -1, resizeModeX = "fill", resizeModeY = "none", name = "contents"})
			}}),
			InputField("", true, "InputField"),
		}}),
		Button(btnText, -100, -12, 0, 70, 24, 1, 1, 1, 1, "none", "confirmButton"),
		Button("Cancel", -15, -12, 0, 70, 24, 1, 1, 1, 1, "none", "cancelButton")
	}})
	self.mountFolderPath = basePath
	self.isPopup = true
	self.callback, self.callbackObj = callback, callbackObj
	self.callbackArgs = {...}

	return self
end

return new
