
local Panel = require "theme.widgets.Panel"
local ResizeHandle = require "theme.widgets.ResizeHandle"

local function new(w, h)
	local mainColumnChildren = {{1, "start"},{2, "start", true},{3, "end"}}
	local mainRowChildren = mainColumnChildren

	-- Screen offset node.
	local root = mod(gui.Node(0, 0, 0, w, h, -1, -1, 0, 0, "fill"), {name = "root", children = {
		-- Main Column
		mod(gui.Column(0, false, mainColumnChildren, 0, 0, 0, w, h, 0, 0, 0, 0, "fill"), {name = "mainColumn", children = {
			-- Menu Bar
			mod(gui.Row(1, false, nil, 0, 0, 0, w, 24, 0, 0, 0, 0, {"fill", "none"}), {name = "menuBar", children = {
				Panel(0, 0, 0, 1, 1, 0, 0, 0, 0, "fill", "menuBarPanel")
			}}),
			-- Main Row
			mod(gui.Row(0, false, mainRowChildren, 0, 0, 0, 10, 10, 0, 0, 0, 0, "fill"), {name = "mainRow", children = {
				-- Left Panel
				mod(gui.Row(nil, nil, {{1,"start",true},{2}}, 0, 0, 0, 200, 10, -1, 0, -1, 0, "fill"), {name = "leftPanel", children = {
					Panel(0, 0, 0, 10, 10, -1, 0, -1, 0, "fill", "panel"),
					ResizeHandle(0, 0, 0, 4, 10, 1, 0, 1, 0, {"none", "fill"})
				}}),
				-- Viewport
				mod(gui.Node(0, 0, 0, 10, 10, 0, 0, 0, 0, "fill"), {name = "viewport"}),
				-- Right Panel
				mod(gui.Row(nil, nil, {{1,"end",true},{2}}, 0, 0, 0, 200, 10, 1, 0, 1, 0, "fill"), {name = "rightPanel", children = {
					Panel(0, 0, 0, 10, 10, 1, 0, 1, 0, "fill", "panel"),
					ResizeHandle(0, 0, 0, 4, 10, -1, 0, -1, 0, {"none", "fill"})
				}})
			}}),
			-- Status Bar
			mod(gui.Row(1, false, nil, 0, 0, 0, w, 24, 0, 0, 0, 0, {"fill", "none"}), {name = "statusBar", children = {
				Panel(0, 0, 0, 1, 1, 0, 0, 0, 0, "fill", "statusBarPanel")
			}})
		}})
	}})
	return root
end

return new
