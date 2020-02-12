
local script = {}

local inputManager = require "input-manager"

function script.init(self)
	inputManager.add(self, "bottom")
end

function script.parentResized(self, designW, designH, newW, newH)
	local tlx, tly = self:toWorld(-self.w/2, -self.h/2)
	local brx, bry = self:toWorld(self.w/2, self.h/2)
	local w, h = brx - tlx, bry - tly
	Camera.current:setViewport(tlx, tly, w, h)
end

function script.input(self, name, value, change)
end

return script
