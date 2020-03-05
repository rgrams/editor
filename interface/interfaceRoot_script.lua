
-- Sets up base Ruu stuff.
-- Sends Input to Ruu.
-- Gets .folderDropped callback and sends the path to the files panel.

local script = {}

local active = require "activeData"
local globalShortcuts = require "interface.global-shortcuts"
local ruuInputHandler = require "lib.ruuInputHandler"
local RUU = require "ruu.ruu"
local theme = require "theme.theme"

function script.init(self)
	love.keyboard.setKeyRepeat(true)
	Input.enable(self)

	local ruu = RUU(Input.get, theme)
	self.ruu, active.ruu = ruu, ruu
	self.ruuInput = ruuInputHandler(ruu)

	local layers = { "gui debug", "popupText", "popupWidgets", "popupPanels", "text", "widgets", "panels", "panel backgrounds" }
	ruu:registerLayers(layers)

	local menuBar = scene:get("/root/mainColumn/menuBar")
	ruu:makePanel(menuBar, true)
	local statusBar = scene:get("/root/mainColumn/statusBar")
	ruu:makePanel(statusBar, true)
	local editScenePanel = scene:get("/root/mainColumn/mainRow/editScenePanel")
	ruu:makePanel(editScenePanel, true)
	local leftPanel = scene:get("/root/mainColumn/mainRow/leftPanel")
	ruu:makePanel(leftPanel, true)
	local viewport = scene:get("/root/mainColumn/mainRow/editScenePanel/VPColumn/Viewport")
	ruu:makePanel(viewport, true)
	local rightPanel = scene:get("/root/mainColumn/mainRow/editScenePanel/rightPanel")
	ruu:makePanel(rightPanel, true)

	local rightPanelHandle = scene:get("/root/mainColumn/mainRow/editScenePanel/rightPanel/resizeHandle")
	ruu:makeButton(rightPanelHandle, true, nil, "ResizeHandle")
	local leftPanelHandle = scene:get("/root/mainColumn/mainRow/leftPanel/resizeHandle")
	ruu:makeButton(leftPanelHandle, true, nil, "ResizeHandle")

	local propPanelMask = scene:get("/root/mainColumn/mainRow/editScenePanel/rightPanel/Properties/Column/Mask")
	ruu:makeScrollArea(propPanelMask, true)
	local propPanel = scene:get("/root/mainColumn/mainRow/editScenePanel/rightPanel/Properties")
	ruu:makePanel(propPanel, true)

	local filesPanelMask = scene:get("/root/mainColumn/mainRow/leftPanel/Files/Column/Mask")
	ruu:makeScrollArea(filesPanelMask, true)
	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/Files")
	ruu:makePanel(filesPanel, true)
	filesPanel.ruu = ruu

	ruu:setFocus(viewport)
end

local projectMountName = "project"

function script.folderDropped(self, absPath)
	if self.projectPath then
		love.filesystem.unmount(self.projectPath)
	end
	self.projectPath = absPath
	love.filesystem.mount(self.projectPath, projectMountName)

	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/Files")
	filesPanel:call("setFolder", projectMountName)
end

function script.parentResized(self, designW, designH, newW, newH, scale, ox, oy)
	self.ruuInput.w, self.ruuInput.h = newW, newH
end

function script.input(self, action, value, change, isRepeat, x, y, dx, dy)
	globalShortcuts.input(self, action, value, change, isRepeat, x, y, dx, dy)
	return self.ruuInput:input(action, value, change, isRepeat, x, y, dx, dy)
end

return script
