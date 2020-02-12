
local script = {}

local inputManager = require "input-manager"

local PopupMenu = require "PopupMenu"

function script.init(self)
	inputManager.add(self, "bottom")
end

function script.parentResized(self, designW, designH, newW, newH)
	local tlx, tly = self:toWorld(-self.w/2, -self.h/2)
	local brx, bry = self:toWorld(self.w/2, self.h/2)
	local w, h = brx - tlx, bry - tly
	Camera.current:setViewport(tlx, tly, w, h)
end

local function addObject(objType, wx, wy)
	print("Add Object: " .. tostring(objType), wx, wy)
end

function script.input(self, name, value, change)
	if name == "add object" and change == 1 then
		if Input.get("lshift").value == 1 or Input.get("rshift").value == 1 then
			local objList = { "Object", "Sprite", "Camera" }
			local sx, sy = love.mouse.getPosition()
			local wx, wy = Camera.current:screenToWorld(sx, sy)
			local lx, ly = self:toLocal(sx, sy)
			scene:add(PopupMenu(lx - 50, ly - 12, "Add Object...", objList, addObject, wx, wy), self)
		end
	end
end

return script
