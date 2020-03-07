
local tex = require "theme.textures"
local fnt = require "theme.fonts"

local pivotForTextAlign = { left = -1, center = 0, right = 1, justify = -1 }

local function new(text, isPopup, name, align, resize, w, h)
	text = text or ""
	name = name or "InputField"
	align = align or "left"
	local textPX = pivotForTextAlign[align]
	w, h = w or 70, h or 24
	resize = resize or "fill"
	local layer = isPopup and "popupWidgets" or "widgets"
	local txtLayer = isPopup and "popupText" or "text"
	local self = mod(gui.Slice(tex.InputField_Normal, nil, {3}, 0, 0, 0, w, h, 0, 0, 0, 0, resize, 1, 3), {layer = layer, name = name or text, children = {
		mod(gui.Mask(nil, 0, 0, 0, 10, 10, 	0, 0, 0, 0, "fill"), {children = {
			mod(gui.Text(text, fnt.default, 0, -1, 0, 1000, textPX, 0, textPX, 0, align, "none"), {layer = txtLayer, name = "Text"})
		}})
	}})
	return self
end

return new
