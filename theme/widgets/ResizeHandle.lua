
local tex = require "theme.textures"

local function new(x, y, angle, w, h, px, py, ax, ay, resizeMode, name)
	local self = gui.Slice(
		tex.ResizeHandle_Normal, nil, {2}, x, y, angle, w, h, px, py, ax, ay, resizeMode
	)
	local handle = gui.Sprite(tex.ResizeHandleHandle, 0, 0, 0, 1, 2)
	self.children = { handle }
	self.name = name or "resizeHandle"
	self.layer = "panel"
	return self
end

return new
