
local fnt = require "theme.fonts"
local script = require "popupMenu_script"
local Panel = require "theme.widgets.Panel"
local Button = require "theme.widgets.Button"

local function new(sx, sy, title, items, callback, ...)
	local self = Panel(sx, sy, 0, 100, #items*24, -1, -1, 0, 0, "none", "popupMenu_" .. title)

	local columnLayoutChildren = {}
	local buttons = {}
	for i,itemText in ipairs(items) do
		local b = Button(itemText, 0, 0, 0, 100, 24, 0, 0, 0, 0, {"fill", "none"})
		b.layer = "popupWidget"
		b.label.layer = "popupText"
		b.parentMenu = self
		table.insert(buttons, b)
		table.insert(columnLayoutChildren, {b})
	end

	local column = gui.Column(1, nil, columnLayoutChildren, 0, 0, 0, 100, 100, 0, 0, 0, 0, "fill")
	column.children = buttons
	local titleText = gui.Text(title, fnt.openSans_Reg_12, 0, -10, 0, 100, -1, 1, -1, -1)

	self.layer, titleText.layer = "popupPanels", "popupText"

	self.callbackArgs = {...}
	self.children = { titleText, column }
	self.script = { script }
	self.callback = callback
	self.buttons = buttons

	return self
end

return new
