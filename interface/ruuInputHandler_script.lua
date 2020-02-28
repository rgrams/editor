
-- Gets input and sends it to the main Ruu instance.
-- Loops mouse to window while Ruu is dragging.

local script = {}

local activeData = require "activeData"
local ruuInputHandler = require "lib.ruuInputHandler"

function script.init(self)
	Input.enable(self)
	self.ruu = activeData.ruu
	self.ruuInput = ruuInputHandler(self.ruu)
end

function script.parentResized(self, designW, designH, newW, newH, scale, ox, oy)
	self.ruuInput.w, self.ruuInput.h = newW, newH
end

function script.input(self, action, value, change, isRepeat, x, y, dx, dy)
	if action == "pan" then
		if change == 1 then
			local widget = self.ruu:focusAtCursor()
			if widget then
				self.ruu:startDrag(widget, "pan")
			end
		elseif change == -1 then
			self.ruu:stopDrag("type", "pan")
		end
	end

	self.ruuInput:input(action, value, change, isRepeat, x, y, dx, dy)
end

return script
