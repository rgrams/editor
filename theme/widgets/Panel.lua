
local tex = require "theme.textures"

local function new(x, y, angle, w, h, px, py, ax, ay, resizeMode, name, padX, padY)
	local self = gui.Slice(
		tex.Panel, nil, {2}, x, y, angle, w, h, px, py, ax, ay, resizeMode, padX, padY
	)
	self.color[1], self.color[2], self.color[3] = 0.75, 0.75, 0.75
	self.name = name or "panel"
	self.layer = "panel"
	return self
end

return new
