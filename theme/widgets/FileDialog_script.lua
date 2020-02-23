
local script = {}

local inputStack = require "lib.input-stack"
local RUU = require "ruu.ruu"
local theme = require "theme.theme"

local function confirm(self)
	self.dialog:call("close")
end

local function cancel(self)
	self.dialog:call("close")
end

function script.init(self)
	inputStack.add(self, "top", false)
	self.ruu = RUU(theme)

	local layers = { "gui debug", "popupText", "popupWidgets", "popupPanels", "text", "widgets", "panels" }
	self.ruu:registerLayers(layers)

	self.ruu:makePanel(self, true)

	self.filesBox = scene:get(self.path .. "/Column/Mask")
	self.ruu:makeScrollArea(self.filesBox, true)
	self.filesBox.ruu = self.ruu
	self.filesBox.showSingleFolder = true

	local confirmButton = scene:get(self.path .. "/confirmButton")
	local cancelButton = scene:get(self.path .. "/cancelButton")
	confirmButton.dialog, cancelButton.dialog = self, self
	self.ruu:makeButton(confirmButton, true, confirm)
	self.ruu:makeButton(cancelButton, true, cancel)

	self.basePathLabel = scene:get(self.path .. "/Column/basePath")

	local mx, my = love.mouse.getPosition()
	self.ruu:mouseMoved(mx, my, 0, 0)

	self.filesBox:call("setFolder", self.basePath)
end

function script.close(self, itemText)
	inputStack.remove(self)
	-- if self.callback then
		-- self.callback(itemText, unpack(self.callbackArgs))
	-- end
	scene:remove(self)
end

local dirs = { up = "up", down = "down", left = "left", right = "right" }

function script.input(self, name, value, change)
	if name == "left click" then
		self.ruu:input("click", nil, change)
	elseif name == "confirm" then
		self.ruu:input("enter", nil, change)
	elseif dirs[name] then
		self.ruu:input("direction", dirs[name], change)
	elseif name == "scroll x" then
		self.ruu:input("scroll x", nil, value)
	elseif name == "scroll y" then
		self.ruu:input("scroll y", nil, value)
	elseif name == "text" then
		self.ruu:input("text", nil, value)
	elseif name == "backspace" and value == 1 then
		self.ruu:input("backspace")
	elseif name == "cancel" and change == 1 then
		self:call("close")
	end

	local basePanel = self.filesBox --self.ruu.focusedPanels[1] or self.ruu.focusedWidget
	if basePanel and basePanel ~= self then
		basePanel:call("input", name, value, change)
		self.basePathLabel.text = self.filesBox.basePath
	end
	return true -- Consume all input.
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
	return true -- Consume all input.
end

return script
