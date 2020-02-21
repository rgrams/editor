
local Panel = require "theme.widgets.Panel"
local ListPanel = require "theme.widgets.ListPanel"
local ResizeHandle = require "theme.widgets.ResizeHandle"

local interface = require "interface.interface_script"
local screencastInput = require "interface.screencastInput_script"
local viewport = require "viewport.viewport"
local input_getter = require "input_getter"
local viewport_background = require "viewport.viewport_background"
local viewport_overlay = require "viewport.viewport_overlay"
local propertiesPanel = require "interface.propertiesPanel_script"
local filesPanel = require "interface.filesPanel_script"

local function new(w, h)
	local mainColumnChildren = {{1, "start"},{2, "start", true},{3, "end"}}
	local mainRowChildren = mainColumnChildren

	-- Screen offset node.
	local root = mod(gui.Node(0, 0, 0, w, h, -1, -1, 0, 0, "fill"), {name = "root", layer = "panels", script = interface, children = {
		mod(gui.Node(0, 0, 0, 1, 1, 0, 0, 0, 0, "fill"), {name = "overlay", layer = "gui overlay", script = {screencastInput}}),
		-- Main Column
		mod(gui.Column(0, false, mainColumnChildren, 0, 0, 0, w, h, 0, 0, 0, 0, "fill"), {name = "mainColumn", children = {
			-- Menu Bar
			mod(gui.Row(1, false, nil, 0, 0, 0, w, 24, 0, 0, 0, 0, {"fill", "none"}), {name = "menuBar", children = {
				mod(Panel(0, 0, 0, 1, 1, 0, 0, 0, 0, "fill", "panel"), {layer = "panel backgrounds"})
			}}),
			-- Main Row
			mod(gui.Row(0, false, mainRowChildren, 0, 0, 0, 10, 10, 0, 0, 0, 0, "fill"), {name = "mainRow", children = {
				-- Left Panel
				mod(gui.Row(nil, nil, {{1,"start",true},{2}}, 0, 0, 0, 200, 10, -1, 0, -1, 0, "fill"), {name = "leftPanel", children = {
					ListPanel(0, 0, 0, 10, 10, -1, 0, -1, 0, "fill", "Files", nil, filesPanel),
					ResizeHandle(0, 0, 0, 4, 10, 1, 0, 1, 0, {"none", "fill"}, "/root/mainColumn/mainRow/leftPanel", -1)
				}}),
				-- Viewport
				mod(gui.Node(0, 0, 0, 10, 10, 0, 0, 0, 0, "fill"), {name = "viewport", script = {viewport}}),
				-- Right Panel
				mod(gui.Row(nil, nil, {{1,"end",true},{2}}, 0, 0, 0, 200, 10, -1, 0, -1, 0, "fill"), {name = "rightPanel", children = {
					ListPanel(0, 0, 0, 10, 10, -1, 0, -1, 0, "fill", "Properties", nil, propertiesPanel),
					ResizeHandle(0, 0, 0, 4, 10, -1, 0, -1, 0, {"none", "fill"}, "/root/mainColumn/mainRow/rightPanel", 1)
				}})
			}}),
			-- Status Bar
			mod(gui.Row(1, false, nil, 0, 0, 0, w, 24, 0, 0, 0, 0, {"fill", "none"}), {name = "statusBar", children = {
				mod(Panel(0, 0, 0, 1, 1, 0, 0, 0, 0, "fill", "statusBarPanel"), {layer = "panel backgrounds"})
			}})
		}})
	}})
	local viewportCamera = Camera(0, 0, 0, 1, "expand view")
	local viewportBackground = mod(Object(0, 0), {
		name = "viewportBackground",
		layer = "viewportBackground",
		script = {viewport_background}
	})
	local viewportOverlay = mod(Object(0, 0), {
		name = "viewportOverlay", layer = "viewportOverlay",
		script = { viewport_overlay }
	})
	local inputGetter = mod(Object(), {name = "input getter", script = input_getter})
	return {root, viewportCamera, viewportBackground, viewportOverlay, inputGetter}
end

return new
