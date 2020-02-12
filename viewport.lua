
local script = {}

local encoder = require "parser"
local classConstructorArgs = require "class-constructor-args"
local inputManager = require "input-manager"
local PopupMenu = require "PopupMenu"

local drawLayers = {
	editScene = { "entities" },
	viewportDebug = { "viewportDebug" }
}
defaultLayer = "entities"
local objList = { "Object", "Sprite", "Text", "World" }
local objClasses = {
	Object = Object,
	Sprite = Sprite,
	Text = Text,
	World = World
}

local function shallowCopy(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
end

function script.init(self)
	inputManager.add(self, "bottom")
	editScene = SceneTree(drawLayers, defaultLayer)
end

local function pan(self, dx, dy)
	dx, dy = Camera.current:screenToWorld(dx, dy, true)
	local camPos = Camera.current.pos
	camPos.x, camPos.y = camPos.x - dx, camPos.y - dy
end

function script.parentResized(self, designW, designH, newW, newH)
	local tlx, tly = self:toWorld(-self.w/2, -self.h/2)
	local brx, bry = self:toWorld(self.w/2, self.h/2)
	local w, h = brx - tlx, bry - tly
	Camera.current:setViewport(tlx, tly, w, h)
end

local function addObject(objType, wx, wy)
	if not objType then  return  end -- Add object canceled.
	local class = objClasses[objType]
	local argList = classConstructorArgs[objType]
	local NO_DEFAULT = classConstructorArgs.NO_DEFAULT

	local args = {}
	local foundARequiredArg = false
	for i=#argList,1,-1 do -- Loop from end until we find a required arg (one without a default value).
		local argData = argList[i]
		if foundARequiredArg then
			local default, requiredPlaceholder = argData[2], argData[5]
			args[i] = default ~= NO_DEFAULT and default or requiredPlaceholder
		elseif argData[2] == NO_DEFAULT then
			foundARequiredArg = true
			args[i] = argData[5] -- Placeholder value for required arg.
		end
	end
	local obj = class(unpack(args))
	obj.pos.x, obj.pos.y = wx, wy
	editScene:add(obj)
end

function script.mouseMoved(self, x, y, dx, dy)
	if self.panning then
		pan(self, dx ,dy)
	end
end

function script.input(self, name, value, change)
	if name == "add object" and change == 1 then
		if Input.get("lshift").value == 1 or Input.get("rshift").value == 1 then
			local sx, sy = love.mouse.getPosition()
			local wx, wy = Camera.current:screenToWorld(sx, sy)
			local lx, ly = self:toLocal(sx, sy)
			scene:add(PopupMenu(lx - 50, ly - 12, "Add Object...", objList, addObject, wx, wy), self)
		end
	elseif name == "zoom" then
		Camera.current:zoomIn(value * SETTINGS.zoomRate, love.mouse.getPosition())
		pan(self, 0, 0)
	elseif name == "pan" then
		self.panning = value == 1
	end
end

return script
