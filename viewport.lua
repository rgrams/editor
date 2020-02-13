
local script = {}

local encoder = require "parser"
local classConstructorArgs = require "class-constructor-args"
local inputManager = require "input-manager"
local PopupMenu = require "PopupMenu"
local collision = require "viewport-collision"

local drawLayers = {
	editScene = { "entities" },
	viewportDebug = { "viewportDebug" }
}
defaultLayer = "entities"
local objList = { "Object", "Sprite", "Quad", "Text", "World" }
local objClasses = {
	Object = Object,
	Sprite = Sprite,
	Quad = Quad,
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
	self.hoverList = {}
	self.selection = {}
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

local function hitCheckObjects(objects, x, y, list)
	for i,object in ipairs(objects) do
		local dist = collision.hitCheckObj(object, x, y)
		if dist then
			table.insert(list, {object, dist})
		end
		if object.children then
			hitCheckObjects(object.children, x, y, list)
		end
	end
end

local function getClosestHovered(list)
	local minDist, closestObj = math.huge, nil
	for i,v in ipairs(list) do
		local dist = v[2]
		if dist < minDist then
			minDist, closestObj = dist, v[1]
		end
	end
	return closestObj, minDist
end

local function hitCheckEditScene(self, x, y)
	local hitList = {}
	x, y = Camera.current:screenToWorld(x, y)
	hitCheckObjects(editScene.children, x, y, hitList)
	local closest = getClosestHovered(hitList)
	return hitList, closest
end

local function addToSelection(self, obj)
	self.selection[obj] = {dragOX = 0, draxOY = 0}
end

local function removeFromSelection(self, obj)
	self.selection[obj] = nil
end

local function isInSelection(self, obj)
	return self.selection[obj]
end

local function toggleObjSelection(self, obj)
	if isInSelection(self, obj) then  removeFromSelection(self, obj)
	else  addToSelection(self, obj)  end
end

local function clearSelection(self)
	for k,v in pairs(self.selection) do  self.selection[k] = nil  end
end

local function setSelectionDragOffsets(self, sx, sy)
	local wx, wy = Camera.current:screenToWorld(sx, sy)
	for obj,dat in pairs(self.selection) do
		dat.dragOX, dat.dragOY = obj._to_world.x - wx, obj._to_world.y - wy
	end
end

local function addObject(objType, self, wx, wy)
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
	self.hoverList, self.hoveredObj = hitCheckEditScene(self, love.mouse.getPosition())
end

function script.mouseMoved(self, x, y, dx, dy)
	if self.panning then
		pan(self, dx ,dy)
	end

	self.hoverList, self.hoveredObj = hitCheckEditScene(self, x, y)

	if self.dragging then
		if self.draggingSelection then
			local mwx, mwy = Camera.current:screenToWorld(x, y)
			for obj,dat in pairs(self.selection) do
				local objWX, objWY = mwx + dat.dragOX, mwy + dat.dragOY
				local localX, localY = obj.parent:toLocal(objWX, objWY)
				obj.pos.x, obj.pos.y = localX, localY
			end
		end
	end
end

function script.input(self, name, value, change)
	if name == "pan" then
		self.panning = value == 1
	elseif name == "zoom" then
		Camera.current:zoomIn(value * SETTINGS.zoomRate, love.mouse.getPosition())
		pan(self, 0, 0)
	elseif name == "left click" then
		if change == 1 then
			if self.hoveredObj then
				if Input.get("lshift").value == 1 or Input.get("rshift").value == 1 then
					toggleObjSelection(self, self.hoveredObj)
				elseif not isInSelection(self, self.hoveredObj) then
					clearSelection(self)
					addToSelection(self, self.hoveredObj)
				end
			else -- hoverList is empty, clicked on nothing.
				clearSelection(self)
			end
			self.dragging = true
			if isInSelection(self, self.hoveredObj) then
				self.draggingSelection = true
				setSelectionDragOffsets(self, love.mouse.getPosition())
			end
		elseif change == -1 then
			self.dragging = false
			self.draggingSelection = false
		end
	elseif name == "add object" and change == 1 then
		if Input.get("lshift").value == 1 or Input.get("rshift").value == 1 then
			local sx, sy = love.mouse.getPosition()
			local wx, wy = Camera.current:screenToWorld(sx, sy)
			local lx, ly = self:toLocal(sx, sy)
			scene:add(PopupMenu(lx - 50, ly - 12, "Add Object...", objList, addObject, self, wx, wy), self)
		end
	end
end

return script
