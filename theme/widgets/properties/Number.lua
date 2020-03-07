
local tex = require "theme.textures"
local fnt = require "theme.fonts"
local InputField = require "theme.widgets.InputField"

local function ruuInit(self, ruu, key, subKey, valType, callback)
	local inputFld = self.children[1].children[2]
	local inputMask = inputFld.children[1]
	local inputTxt = inputMask.children[1]
	local scrollToRight = key == "image"
	ruu:makeInputField(inputFld, inputTxt, inputMask, true, nil, callback, scrollToRight)
	self.ruuWidget = inputFld
	inputFld._propKey, inputFld._propSubKey = key, subKey
	inputFld._propName, inputFld._valType = self.name, valType
end

local function _new(labelTxt, value)
	assert(labelTxt, "PropertyWidget - can't create without a label name.")
	local w, h = 200, 24
	local labelW = new.font(unpack(fnt.default)):getWidth(labelTxt) + 8
	labelW = math.max(labelW, w/3)
	local self = mod(gui.Slice(tex.Panel, nil, {2}, 0, 0, 0, w, h, 0, 0, 0, 0, {"fill", "none"}), {name = labelTxt, layer = "widgets", children = {
		mod(gui.Row(0, false, {{1,"start",false},{2,"end",true}}, 0, 0, 0, w, h, 0, 0, 0, 0, "fill"), {children = {
			mod(gui.Text(labelTxt, fnt.default, 3, -1, 0, labelW, -1, 0, -1, 0, "left", "fill"), {layer = "text"}),
			InputField(value, false, "input", "center", "fill", w/2, h)
		}})
	}, color = {0.75, 0.75, 0.75, 1}, ruuInit = ruuInit})
	return self
end

return _new
