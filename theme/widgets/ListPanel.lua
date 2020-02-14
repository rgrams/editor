
local fnt = require "theme.fonts"
local tex = require "theme.textures"
local Panel = require "theme.widgets.Panel"

local function new(x, y, angle, w, h, px, py, ax, ay, resizeMode, title, name, script)
	local self = mod(Panel(x, y, angle, w, h, px, py, ax, ay, resizeMode, name), {children = {
		mod(gui.Column(nil, nil, {{1},{2,"start",true}}, 0, 0, 0, w, h, 0, 0, 0, 0, "fill"), {children = {
			-- Title Bar
			mod(Panel(0, 0, 0, w, 24, 0, -1, 0, -1, {"fill", "none"}, "titleBar"), {children = {
				mod(gui.Text(title, fnt.panelTitle, 0, 0, 0, 200, -1, 0, -1, 0, "center", "fill"), {name = "text", layer = "text"})
			}}),
			-- Mask
			mod(gui.Mask(nil, 0, 0, 0, w, 10, 0, -1, 0, -1, "fill", 2), {name = title, children = {
				-- Contents Column
				mod(gui.Column(nil, nil, nil, 0, 0, 0, 10, 10, 0, -1, 0, -1, {"fill", "none"}), {layer = "widgets", name = "contents"})
			}, script = script})
		}})
	}})

	return self
end

return new
