
local script = {}

local fnt = require "theme.fonts"

local inputManager = require "input-manager"
local RUU = require "ruu.ruu"
local ruu
local theme = require "theme.theme"

function script.init(self)
	love.keyboard.setKeyRepeat(true)
	inputManager.add(self)

	ruu = RUU(theme)
	local layers = { "gui debug", "popupText", "popupWidgets", "popupPanels", "text", "widgets", "panels" }
	ruu:registerLayers(layers)

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
	end
	if next(ruu.hoveredWidgets) then
		return true
	end
end

function script.mouseMoved(self, x, y, dx, dy)
	return ruu:mouseMoved(x, y, dx, dy)
end

local function addFiles(basePath, files, indentLevel)
	indentLevel = indentLevel or 0
	local indent = string.rep("\t", indentLevel)
	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/panel/column")
	for k,fileName in ipairs(files) do
		local path = basePath .. fileName
		local info = love.filesystem.getInfo(path)
		assert(info, "Failed to load file at path: " .. path)
		local btn = gui.Text(indent .. fileName, fnt.openSans_Reg_12, 0, 0, 0, 200, 0, 0, 0, 0, "left", "fill")
		btn.layer = "text"
		scene:add(btn, filesPanel)
		filesPanel:add(btn)
		if info.type == "directory" then
			addFiles(path .. "/", love.filesystem.getDirectoryItems(path), indentLevel + 1)
		end
	end
end

function love.directorydropped(path)
	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/panel/column")
	love.filesystem.mount(path, "project")
	local files = love.filesystem.getDirectoryItems("project")
	addFiles("project/", files)
end

return script
