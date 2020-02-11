
local tex = require "theme.textures"

local function new(x, y, angle, w, h, px, py, ax, ay, resizeMode, name)
	local self = gui.Slice(
		tex.Panel, nil, {2}, x, y, angle, w, h, px, py, ax, ay, resizeMode
	)
	self.name = name
	self.layer = "panel"
	return self
end

return new
