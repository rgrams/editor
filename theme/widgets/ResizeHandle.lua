
local tex = require "theme.textures"

local function drag(self, dx, dy, isLocal)
	if dx and dy then
		local wx, wy = self._to_world.x + dx, self._to_world.y + dy
		dx, dy = self:toLocal(wx, wy)
		if not self.target then
			return
		end
		if self.target.designW then
			self.target.designW = math.max(self.minSize, self.target.designW - dx * self.dir)
			self.target.parent:refresh()
		end
	end
end

local script = {}

function script.init(self)
	if type(self.target) == "string" then
		self.target = scene:get(self.target)
	end
end

local function new(x, y, angle, w, h, px, py, ax, ay, resizeMode, target, dir, minSize)
	local self = gui.Slice(
		tex.ResizeHandle_Normal, nil, {2}, x, y, angle, w, h, px, py, ax, ay, resizeMode
	)
	local handle = gui.Sprite(tex.ResizeHandleHandle, 0, 0, 0, 1, 2)
	self.children = { handle }
	self.name = "resizeHandle"
	self.layer = "panel backgrounds"
	self.isDraggable = true
	self.target = scene:get(target) or target
	self.dir = dir or 1
	self.minSize = math.max(1, minSize or 1)
	self.drag = drag
	self.script = {script}
	return self
end

return new
