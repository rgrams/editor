
local tex = require "theme.textures"
local fnt = require "theme.fonts"

local function new(text, x, y, angle, w, h, px, py, ax, ay, resizeMode, name)
	w, h = w or 100, h or 100
	local self = gui.Slice(
		tex.Button_Normal, nil, {5, 6}, x, y, angle, w, h, px, py, ax, ay, resizeMode
	)
	local label = gui.Text(text, fnt.default, 0, -1, 0, w, -1, 0, -1, 0, "center", "fill")
	self.label = label
	self.children = { label }
	self.layer = "popupWidgets"
	label.layer = "popupText"
	label.name = "label"
	self.name = name or "button"
	self.color[1], self.color[2], self.color[3] = 0.75, 0.75, 0.75
	return self
end

return new
