
-- Sets up base Ruu stuff.

local script = {}

local activeData = require "activeData"
local RUU = require "ruu.ruu"
local theme = require "theme.theme"

function script.init(self)
	love.keyboard.setKeyRepeat(true)
	local ruu = RUU(theme)
	self.ruu, activeData.ruu = ruu, ruu

	local layers = { "gui debug", "popupText", "popupWidgets", "popupPanels", "text", "widgets", "panels", "panel backgrounds" }
	ruu:registerLayers(layers)

	local menuBar = scene:get("/root/mainColumn/menuBar")
	ruu:makePanel(menuBar, true)
	local statusBar = scene:get("/root/mainColumn/statusBar")
	ruu:makePanel(statusBar, true)
	local leftPanel = scene:get("/root/mainColumn/mainRow/leftPanel")
	ruu:makePanel(leftPanel, true)
	local viewport = scene:get("/root/mainColumn/mainRow/viewport")
	ruu:makePanel(viewport, true)
	ruu:setFocus(viewport)
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
	filesPanel.ruu = ruu
end

return script
