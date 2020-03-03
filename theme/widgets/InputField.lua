
local tex = require "theme.textures"
local fnt = require "theme.fonts"

local function new(text, isPopup, name)
	local layer = isPopup and "popupWidgets" or "widgets"
	local txtLayer = isPopup and "popupText" or "text"
	local self = mod(gui.Slice(tex.Button_Normal, nil, {5,6}, 0, 0, 0, 10, 24, 0, 0, 0, 0, "fill", 5, 3), {layer = layer, name = name or text, children = {
		mod(gui.Mask(nil, 0, 0, 0, 10, 10, 	0, 0, 0, 0, "fill"), {resizeModeX = "fill", resizeModeY = "fill", children = {
			mod(gui.Text(text, fnt.default, 0, 0, 0, 1000, 0, 0, 0, 0, "center", "none"), {layer = txtLayer, name = "Text"})
		}})
	}, color = {0.4, 0.4, 0.4, 1}})
	return self
end

return new
