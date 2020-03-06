
local tex = require "theme.textures"
local fnt = require "theme.fonts"

local function new(label, value, labelW)
	assert(label, "PropertyWidget - can't create without a label name.")
	local w, h = 200, 24
	local self = mod(gui.Slice(tex.Panel, nil, {2}, 0, 0, 0, w, h, 0, 0, 0, 0, {"fill", "none"}), {name = label, layer = "widgets", children = {
		mod(gui.Row(0, false, {{1,"start",false},{2,"end",true}}, 0, 0, 0, w, h, 0, 0, 0, 0, "fill"), {children = {
			mod(gui.Text(label, fnt.default, 0, -1, 0, labelW or w/3, -1, 0, -1, 0, "left", "fill"), {layer = "text"}),
			mod(gui.Slice(tex.InputField_Normal, nil, {3}, 0, 0, 0, w/2, h, 0, 0, 0, 0, "fill", 5, 3), {layer = "widgets", name = "input", children = {
				mod(gui.Mask(), {resizeModeX = "fill", resizeModeY = "fill", children = {
					mod(gui.Text(value, fnt.default, 0, -1, 0, 1000, -1, 0, -1, 0, "left", "none"), {layer = "text", name = "text"})
				}})
			}})
		}})
	}})
	self.color[1], self.color[2], self.color[3] = 0.75, 0.75, 0.75
	return self
end

return new
