
local script = {}

local fnt = require "theme.fonts"

local activeData = require "activeData"
local inputStack = require "lib.input-stack"
local RUU = require "ruu.ruu"
local ruu
local theme = require "theme.theme"

function script.init(self)
	love.keyboard.setKeyRepeat(true)
	inputStack.add(self)

	ruu = RUU(theme)
	activeData.ruu = ruu
	local layers = { "gui debug", "popupText", "popupWidgets", "popupPanels", "text", "widgets", "panels" }
	ruu:registerLayers(layers)

	local menuBar = scene:get("/root/mainColumn/menuBar")
	ruu:makePanel(menuBar, true)
	local statusBar = scene:get("/root/mainColumn/statusBar")
	ruu:makePanel(statusBar, true)
	local leftPanel = scene:get("/root/mainColumn/mainRow/leftPanel")
	ruu:makePanel(leftPanel, true)
	local viewport = scene:get("/root/mainColumn/mainRow/viewport")
	ruu:makePanel(viewport, true)
	local rightPanel = scene:get("/root/mainColumn/mainRow/rightPanel")
	ruu:makePanel(rightPanel, true)

	local rightPanelHandle = scene:get("/root/mainColumn/mainRow/rightPanel/resizeHandle")
	ruu:makeButton(rightPanelHandle, true, nil, "ResizeHandle")
	local leftPanelHandle = scene:get("/root/mainColumn/mainRow/leftPanel/resizeHandle")
	ruu:makeButton(leftPanelHandle, true, nil, "ResizeHandle")

	local propPanel = scene:get("/root/mainColumn/mainRow/rightPanel/panel/Column/Properties")
	ruu:makeScrollArea(propPanel, true)
	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files")
	ruu:makeScrollArea(filesPanel, true)
end

local dirs = { up = "up", down = "down", left = "left", right = "right" }

function script.input(self, name, value, change)
	if name == "left click" then
		return ruu:input("click", nil, change)
	elseif name == "pan" then
		if change == 1 then
			local widget = ruu:focusAtCursor()
			if widget then
				ruu:startDrag(widget, "pan")
			end
		elseif change == -1 then
			ruu:stopDrag("pan")
		end
	elseif name == "confirm" then
		return ruu:input("enter", nil, change)
	elseif dirs[name] then
		return ruu:input("direction", dirs[name], change)
	elseif name == "scroll x" then
		return ruu:input("scroll x", nil, value)
	elseif name == "scroll y" then
		return ruu:input("scroll y", nil, value)
	elseif name == "text" then
		return ruu:input("text", nil, value)
	elseif name == "backspace" and value == 1 then
		return ruu:input("backspace")
	elseif name == "undo/redo" and value == 1 then
		if Input.get("lctrl").value == 1 or Input.get("rctrl").value == 1 then
			if Input.get("lshift").value == 1 or Input.get("rshift").value == 1 then
				local redoCommand, args = activeData.commands:redo()
				print("Redo: " .. tostring(redoCommand))
				if args then  for k,v in pairs(args) do  print("", k,v)  end  end
			else
				local undoCommand, args = activeData.commands:undo()
				print("Undo: " .. tostring(undoCommand))
				if args then  for k,v in pairs(args) do  print("", k,v)  end  end
			end
		end
	end
	if next(ruu.hoveredWidgets) then
		return true
	end
end

function script.mouseMoved(self, x, y, dx, dy)
	if self.ignoreNextMouseDelta then -- The frame after wrapping there will be a screen-sized delta.
		dx, dy = 0, 0
		self.ignoreNextMouseDelta = false
	end
	if ruu.drags then -- Wrap mouse inside window while dragging.
		local mx, my = x + dx, y + dy
		local didWrap
		if mx <= 0 and dx < 0 then
			mx, didWrap = mx + self.w, true
		elseif mx >= self.w and dx > 0 then
			mx, didWrap = mx - self.w, true
		end
		if my <= 0 and dy < 0 then
			my, didWrap = my + self.h, true
		elseif my >= self.h and dy > 0 then
			my, didWrap = my - self.h, true
		end
		if didWrap then
			love.mouse.setPosition(mx, my)
			self.ignoreNextMouseDelta = true
		end
		x, y = mx, my
	end
	return ruu:mouseMoved(x, y, dx, dy)
end

return script
