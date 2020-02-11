
local script = {}

local RUU = require "ruu.ruu"
local ruu
local theme = require "theme.theme"

function script.init(self)
	love.keyboard.setKeyRepeat(true)
	self.mx, self.my = love.mouse.getPosition()
	Input.enable(self)

	ruu = RUU(theme)

	local menuBar = scene:get("/root/mainColumn/menuBar")
	ruu:makePanel(menuBar, true)
	local statusBar = scene:get("/root/mainColumn/statusBar")
	ruu:makePanel(statusBar, true)
	local leftPanel = scene:get("/root/mainColumn/mainRow/leftPanel")
	ruu:makePanel(leftPanel, true)
	local rightPanel = scene:get("/root/mainColumn/mainRow/rightPanel")
	ruu:makePanel(rightPanel, true)

	local rightPanelHandle = scene:get("/root/mainColumn/mainRow/rightPanel/resizeHandle")
	ruu:makeButton(rightPanelHandle, true, nil, "ResizeHandle")
	local leftPanelHandle = scene:get("/root/mainColumn/mainRow/leftPanel/resizeHandle")
	ruu:makeButton(leftPanelHandle, true, nil, "ResizeHandle")
end

local dirs = { up = "up", down = "down", left = "left", right = "right" }

function script.input(self, name, value, change)
	if name == "left click" then
		ruu:input("click", nil, change)
	elseif name == "enter" then
		ruu:input("enter", nil, change)
	elseif dirs[name] then
		ruu:input("direction", dirs[name], change)
	elseif name == "scroll x" then
		ruu:input("scroll x", nil, value)
	elseif name == "scroll y" then
		ruu:input("scroll y", nil, value)
	elseif name == "text" then
		ruu:input("text", nil, value)
	elseif name == "backspace" and value == 1 then
		ruu:input("backspace")
	end
end

function script.update(self, dt)
	local mx, my = love.mouse.getPosition()
	local dx, dy = mx - self.mx, my - self.my
	if dx ~= 0 or dy ~= 0 then
		local hit = ruu:mouseMoved(mx, my, dx, dy)
	end
	self.mx, self.my = mx, my
end

return script
