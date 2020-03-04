
local fnt = require "theme.fonts"
local Panel = require "theme.widgets.Panel"
local Button = require "theme.widgets.PopupButton"
local script = require "theme.widgets.PopupConfirm_script"

local function new(title, text, yesText, noText, callback, callbackObj)
	local w, h = 250, 150
	local self = mod(Panel(0, 0, 0, w, h, 0, 0, 0, 0, "fit", "PopupConfirm"), {layer = "popupPanels", script = {script}, children = {
		mod(gui.Column(15, false, {{1},{2,nil,true},{3}}, 0, 0, 0, 10, 10, 0, 0, 0, 0, "fill"), {children = {
			-- Title
			mod(Panel(0, 0, 0, w, 24, 0, -1, 0, -1, {"fill", "none"}, "titleBar"), {children = {
				mod(gui.Text(title, fnt.panelTitle, 0, 0, 0, 200, 0, 0, 0, 0, "center"), {name = "text", layer = "popupText"})
			}}),
			-- Body Text
			mod(gui.Text(text, fnt.default, 10, 0, 0, w-20, -1, -1, -1, -1, "left", "stretch"), {layer = "popupText"}),
			-- Buttons
			mod(gui.Node(0, 0, 0, 10, 10, 0, 0, 0, 0, "fill", 10), {name = "btnParent", children = {
				Button(yesText or "yes", -100, 0, 0, 70, 24, 1, 1, 1, 1, "none", "confirmButton"),
				Button(noText or "no", -12, 0, 0, 70, 24, 1, 1, 1, 1, "none", "cancelButton")
			}})
		}})
	}})
	self.callback, self.callbackObj = callback, callbackObj
	return self
end

return new
