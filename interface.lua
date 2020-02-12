
local script = {}

local inputManager = require "input-manager"
local RUU = require "ruu.ruu"
local ruu
local theme = require "theme.theme"

function script.init(self)
	love.keyboard.setKeyRepeat(true)
	inputManager.add(self)

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
		return ruu:input("click", nil, change)
	elseif name == "enter" then
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
	end
end

function script.mouseMoved(self, x, y, dx, dy)
	return ruu:mouseMoved(x, y, dx, dy)
end

return script
