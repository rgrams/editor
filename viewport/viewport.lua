
local script = {}

local FileDialog = require "theme.widgets.FileDialog"
local encoder = require "lib.encoder"
local activeData = require "activeData"
local CommandHistory = require "philtre.commands"
local allCommands = require "commands.all-commands"
local Selection = require "Selection"
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

local function saveToAbsolutePath(data, absPath)
	local file, errorMsg = io.open(absPath, "w")
	if file then
		file:write(data)
		file:close()
		print("    Success!")
	else
		print(errorMsg)
	end
	return file, errorMsg
end

local function saveSceneFile(self, mountedPath, absFilepath, obj)
	if absFilepath then
		print("Saving to Path: "..absFilepath)
		-- Filepath has already been checked, if it's an overwrite then it's already been confirmed.
		local data = encoder.encode(obj)
		-- Use `mountedPath` to check the file.
		-- Use `absFilepath` to write the file.
		local info = love.filesystem.getInfo(mountedPath)
		if info then
			print("  Saving over existing file "..mountedPath)
			saveToAbsolutePath(data, absFilepath)
		end
		if not info then
			print("  Writing new file "..absFilepath)
			saveToAbsolutePath(data, absFilepath)
		end
	end
end

local function shallowCopy(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
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

local function updateCursorCollision(self, mx, my)
	self.hoverList, self.hoveredObj = hitCheckEditScene(self, mx, my)
end

local function pan(self, dx, dy)
	dx, dy = Camera.current:screenToWorld(dx, dy, true)
	local camPos = Camera.current.pos
	camPos.x, camPos.y = camPos.x - dx, camPos.y - dy
end

local function drag(self, dx, dy, dragType)
	if dragType == "pan" then
		pan(self, dx, dy)
	end
end

local function scroll(self, dx, dy)
	Camera.current:zoomIn(dy * SETTINGS.zoomRate, love.mouse.getPosition())
	pan(self, 0, 0)
end

local function press(self, mx, my, isKeyboard)
	if isKeyboard then  return  end

	updateCursorCollision(self, mx, my)
	if self.hoveredObj then
		if Input.get("shift") == 1 then
			self.cmd:perform("toggleObjSelection", self.selection, self.hoveredObj[PRIVATE_KEY])
		elseif not self.selection._[self.hoveredObj[PRIVATE_KEY]] then
			self.cmd:perform("setSelectionTo", self.selection, self.hoveredObj[PRIVATE_KEY])
		end
	else -- hoverList is empty, clicked on nothing.
		self.cmd:perform("clearSelection", self.selection)
	end
	self.dragging = true
	if self.hoveredObj and self.selection._[self.hoveredObj[PRIVATE_KEY]] then
		self.draggingSelection = "start"
		local wx, wy = Camera.current:screenToWorld(love.mouse.getPosition())
		for enclosure,data in pairs(self.selection._) do -- updateDragOffsets
			local obj = enclosure[1]
			data.dragOX, data.dragOY = obj._to_world.x - wx, obj._to_world.y - wy
		end
	end
end

local function release(self, mx, my, isKeyboard)
	if isKeyboard then  return  end

	self.dragging = false
	self.draggingSelection = false
end

local function mouseMoved(self, x, y, dx, dy)
	updateCursorCollision(self, x, y)

	if self.dragging then
		if self.draggingSelection then
			local isStart = self.draggingSelection == "start"
			local mwx, mwy = Camera.current:screenToWorld(x, y)
			local roundTo = SETTINGS.roundAllNumbersTo

			local args = {}
			for enclosure,dat in pairs(self.selection._) do
				local obj = enclosure[1]
				local wx, wy = mwx + dat.dragOX, mwy + dat.dragOY
				local lx, ly = obj.parent:toLocal(wx, wy)
				lx, ly = math.round(lx, roundTo), math.round(ly, roundTo)
				obj.pos.x, obj.pos.y = lx, ly
				obj:updateTransform()
				table.insert(args, {enclosure, "pos", lx, "x"})
				table.insert(args, {enclosure, "pos", ly, "y"})
			end
			if isStart then
				self.cmd:perform("setSeparate", args)
				self.draggingSelection = "not start"
			else
				self.cmd:update(args)
				activeData.propertiesPanel:call("updateSelection")
			end
		end
	end
end

function script.init(self)
	editScene = SceneTree(drawLayers, defaultLayer)
	self.hoverList = {}
	self.selection = Selection()
	activeData.selection = self.selection
	self.cmd = CommandHistory(allCommands)
	activeData.commands = self.cmd
	self.isDraggable = true
	self.drag, self.scroll = drag, scroll
	self.pressFunc, self.releaseFunc = press, release
	self.mouseMovedFunc = mouseMoved
end

function script.parentResized(self, designW, designH, newW, newH)
	local tlx, tly = self:toWorld(-self.w/2, -self.h/2)
	local brx, bry = self:toWorld(self.w/2, self.h/2)
	local w, h = brx - tlx, bry - tly
	Camera.current:setViewport(tlx, tly, w, h)
end

local function addMenuClosed(className, self, wx, wy)
	if not className then  return  end -- Add object canceled.

	if not next(self.selection._) then -- Add a single object in world space.
		local roundTo = SETTINGS.roundAllNumbersTo
		wx, wy = math.round(wx, roundTo), math.round(wy, roundTo)
		self.cmd:perform("addObject", className, {}, editScene, false, { pos = {x=wx, y=wy} })
	else -- Have something selected - Add duplicate objects as children to each of them.
		local multiAddArgs = {}
		local enclosureList = self.selection:getEnclosureList()
		for i,enclosure in ipairs(enclosureList) do
			local parent = enclosure[1]
			local lx, ly = parent:toLocal(wx, wy)
			local roundTo = SETTINGS.roundAllNumbersTo
			lx, ly = math.round(lx, roundTo), math.round(ly, roundTo)
			local addArgs = {className, {}, editScene, enclosure, { pos = {x=lx, y=ly} }}
			table.insert(multiAddArgs, addArgs)
		end
		self.cmd:perform("addMultiple", multiAddArgs)
	end

	updateCursorCollision(self, love.mouse.getPosition())
end

function script.ruuinput(self, name, value, change, isRepeat, x, y, dx, dy, isTouch, presses)
	if name == "mouseMoved" then
		mouseMoved(self, x, y, dx, dy)
	elseif name == "pan" then
		local ruu = activeData.ruu
		if change == 1 then
			local widget = ruu:focusAtCursor()
			if widget then
				ruu:startDrag(widget, "pan")
			end
		elseif change == -1 then
			ruu:stopDrag("type", "pan")
		end
	elseif name == "add object" and change == 1 then
		local sx, sy = love.mouse.getPosition()
		local wx, wy = Camera.current:screenToWorld(sx, sy)
		local lx, ly = self:toLocal(sx, sy)
		scene:add(PopupMenu(lx - 50, ly - 12, "Add Object...", objList, addMenuClosed, self, wx, wy), self)
	elseif name == "remove object" and change == 1 then
		local enclosureList = self.selection:getEnclosureList()
		if #enclosureList > 0 then
			self.cmd:perform("removeAllSelected", self.selection)
			updateCursorCollision(self, love.mouse.getPosition())
		end
	elseif name == "test" and change == 1 then
		print("TEST")
		local enclosureList = self.selection:getEnclosureList()
		self.cmd:perform("set", enclosureList, "pos", 0, "y")
	elseif name == "copy" and change == 1 then
		self.cmd:perform("copySelection", self.selection)
	elseif name == "cut" and change == 1 then
		self.cmd:perform("cutSelection", self.selection)
		updateCursorCollision(self, love.mouse.getPosition())
	elseif name == "paste" and change == 1 then
		self.cmd:perform("pasteOntoSelection", self.selection)
		updateCursorCollision(self, love.mouse.getPosition())
	elseif name == "save" and change == 1 then
		local obj = editScene.children[1]
		local dialog = FileDialog("project", "Save", saveSceneFile, self, obj)
		local root = scene:get("/root")
		scene:add(dialog, root)
	end
end

return script
