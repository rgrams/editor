
local tex = require "theme.textures"
local fnt = require "theme.fonts"

local function new(text, path)
	local self = mod(gui.Slice(tex.Panel, nil, {2}, 0, 0, 0, 100, 24, -1, 0, -1, 0, {"fill", "none"}), {
		filepath = path,
		color = {0.75, 0.75, 0.75, 1},
		name = text,
		layer = "widgets",
		children = {
			mod(gui.Text(text, fnt.files, 0, -1, 0, 600, -1, 0, -1, 0, "left", "none"), {
				name = "label",
				layer = "text"
			})
		}
	})
	self.label = self.children[1]
	return self
end

return new
