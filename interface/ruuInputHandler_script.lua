
-- Gets input and sends it to the main Ruu instance.
-- Loops mouse to window while Ruu is dragging.

local script = {}

local activeData = require "activeData"

function script.init(self)
	Input.enable(self)
	self.ruu = activeData.ruu
end

function script.mouseMoved(self, x, y, dx, dy)
	if self.ignoreNextMouseDelta then -- The frame after wrapping there will be a screen-sized delta.
		dx, dy = 0, 0
		self.ignoreNextMouseDelta = false
	end
	if self.ruu.drags then -- Wrap mouse inside window while dragging.
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
			x, y = mx, my
		end
	end
	self.ruu:mouseMoved(x, y, dx, dy)
end

local dirs = { up = "up", down = "down", left = "left", right = "right" }

function script.input(self, name, value, change, isRepeat, x, y, dx, dy)
	if name == "mouseMoved" then
		script.mouseMoved(self, x, y, dx, dy)
	elseif name == "left click" then
		self.ruu:input("click", nil, change)
	elseif name == "pan" then
		if change == 1 then
			local widget = self.ruu:focusAtCursor()
			if widget then
				self.ruu:startDrag(widget, "pan")
			end
		elseif change == -1 then
			self.ruu:stopDrag("type", "pan")
		end
	elseif name == "enter" then
		self.ruu:input("enter", nil, change)
	elseif dirs[name] then
		self.ruu:input("direction", dirs[name], value)
	elseif name == "next" and value == 1 then
		self.ruu:input("direction", "prev", value)
	elseif name == "prev" and value == 1 then
		self.ruu:input("direction", "next", value)
	elseif name == "scroll x" then
		self.ruu:input("scroll x", nil, value)
	elseif name == "scroll y" then
		self.ruu:input("scroll y", nil, value)
	elseif name == "text" then
		self.ruu:input("text", nil, value)
	elseif name == "backspace" and value == 1 then
		self.ruu:input("backspace")
	elseif name == "delete" and value == 1 then
		self.ruu:input("delete")
	elseif name == "back" and value == 1 then
		local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files")
		if filesPanel.isHovered then
			filesPanel:call("goUp")
		end
	end

	local basePanel = self.ruu.focusedPanels[1] or self.ruu.focusedWidget
	if basePanel then
		basePanel:call("input", name, value, change, isRepeat, x, y, dx, dy)
	end
end

return script
