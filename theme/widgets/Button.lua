
local tex = require "theme.textures"
local fnt = require "theme.fonts"

local function new(text, x, y, angle, w, h, px, py, ax, ay, resizeMode, name)
	w, h = w or 100, h or 100
	local self = gui.Slice(
		tex.Button_Normal, nil, {5, 6}, x, y, angle, w, h, px, py, ax, ay, resizeMode
	)
	local label = gui.Text(text, fnt.openSans_Reg_12, 0, -1, 0, w, -1, 0, -1, 0, "center", "fill")
	label.layer = "text"
	label.name = "label"
	self.label = label
	self.children = { label }
	self.color[1], self.color[2], self.color[3] = 0.75, 0.75, 0.75
	self.name = name or "button"
	self.layer = "widgets"
	return self
end

return new
