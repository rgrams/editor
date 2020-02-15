
local script = {}

local activeData = require "activeData"
local CommandHistory = require "philtre.commands"
local allCommands = require "commands.all-commands"
local Selection = require "Selection"
local encoder = require "lib.encoder"
local classConstructorArgs = require "object.class-constructor-args"
local inputManager = require "lib.input-manager"
require "object.object-debugDraw-overrides"
local collision = require "viewport.viewport-collision"
local PopupMenu = require "theme.widgets.PopupMenu"

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
	self.selection = Selection()
	activeData.selection = self.selection
	self.cmd = CommandHistory(allCommands)
	activeData.commands = self.cmd
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

local function addMenuClosed(objType, self, wx, wy)
	if not objType then  return  end -- Add object canceled.

	-- TODO: convert to local pos if parent exists.
	self.cmd:perform("addObject", objType, {}, editScene, wx, wy, parent)
	self.hoverList, self.hoveredObj = hitCheckEditScene(self, love.mouse.getPosition())
end

function script.mouseMoved(self, x, y, dx, dy)
	if self.panning then
		pan(self, dx ,dy)
	end

	self.hoverList, self.hoveredObj = hitCheckEditScene(self, x, y)

	if self.dragging then
		if self.draggingSelection then
			local isStart = self.draggingSelection == "start"
			local mwx, mwy = Camera.current:screenToWorld(x, y)
			for obj,dat in pairs(self.selection._) do
				local wx, wy = mwx + dat.dragOX, mwy + dat.dragOY
				local lx, ly = obj.parent:toLocal(wx, wy)
				local enclosure = obj[PRIVATE_KEY]
				if isStart then
					self.cmd:perform("setPosition", enclosure, lx, ly)
				else
					obj.pos.x, obj.pos.y = lx, ly
					activeData.propertiesPanel:call("setProperty", obj, "pos", lx, "x")
					activeData.propertiesPanel:call("setProperty", obj, "pos", ly, "y")
					self.cmd:update(enclosure, lx, ly)
				end
			end
			if isStart then
				self.draggingSelection = true
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
					self.cmd:perform("toggleObjSelection", self.selection, self.hoveredObj[PRIVATE_KEY])
				elseif not self.selection._[self.hoveredObj] then
					self.cmd:perform("setSelectionTo", self.selection, self.hoveredObj[PRIVATE_KEY])
				end
			else -- hoverList is empty, clicked on nothing.
				self.cmd:perform("clearSelection", self.selection)
			end
			self.dragging = true
			if self.selection._[self.hoveredObj] then
				self.draggingSelection = "start"
				local wx, wy = Camera.current:screenToWorld(love.mouse.getPosition())
				for obj,data in pairs(self.selection._) do -- updateDragOffsets
					data.dragOX, data.dragOY = obj._to_world.x - wx, obj._to_world.y - wy
				end
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
			scene:add(PopupMenu(lx - 50, ly - 12, "Add Object...", objList, addMenuClosed, self, wx, wy), self)
		end
	end
end

return script
