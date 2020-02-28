
-- Gets input and sends it to the main Ruu instance.
-- Loops mouse to window while Ruu is dragging.

local function wrapMouse(self, x, y, dx, dy)
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
	return x, y, dx, dy
end

local hoverActions = {
	pan = 1, scrollx = 1, scrolly = 1
}
-- Anything not a hover action is assumed to be a focus action.

local function input(self, action, value, change, isRepeat, x, y, dx, dy)
	if action == "mouseMoved" then
		x, y, dx, dy = wrapMouse(self, x, y, dx, dy)
		self.ruu:mouseMoved(x, y, dx, dy)
	else
		local actionType = hoverActions[action] and "hover" or "focus"
		return self.ruu:input(actionType, action, value, change, isRepeat, x, y, dx, dy)
	end
end

local function new(ruu)
	local w, h = love.window.getMode()
	local self = {
		ruu = ruu,
		input = input,
		ignoreNextMouseDelta = false,
		w = w, h = h
	}
	return self
end

return new
