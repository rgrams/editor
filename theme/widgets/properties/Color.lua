
local tex = require "theme.textures"
local fnt = require "theme.fonts"
local InputField = require "theme.widgets.InputField"

local fields = {"r", "g", "b", "a"}

local function ruuInit(self, ruu, key, subKey, valType, callback)
	self.ruu = ruu
	self.ruuWidgets = {}
	local inputRow = self.children[1].children[2]
	for i,v in ipairs(fields) do
		local inputFld = inputRow.children[i*2]
		local inputMask = inputFld.children[1]
		local inputTxt = inputMask.children[1]
		ruu:makeInputField(inputFld, inputTxt, inputMask, true, nil, callback)
		inputFld._propKey, inputFld._propSubKey = key, i
		inputFld._propName, inputFld._valType = self.name, valType
		self.ruuWidgets[i] = inputFld
	end
end

local function setValue(self, value)
	for i,v in ipairs(self.ruuWidgets) do
		v:setText(tostring(value[i]))
	end
end

local function updateScroll(self)
	for i,v in ipairs(self.ruuWidgets) do
		v:updateScroll()
	end
end

local function final(self)
	for i,v in ipairs(self.ruuWidgets) do
		self.ruu:destroyWidget(v)
	end
end

local function _new(labelTxt, value)
	assert(labelTxt, "PropertyWidget - can't create without a label name.")
	local w, h = 200, 24
	local font = new.font(unpack(fnt.default))
	local labelW = font:getWidth(labelTxt) + 8
	labelW = math.max(labelW, w/3)
	local subLabelW = font:getWidth("rgba") / 4 + 1
	local inputW = (w/2 - subLabelW * 4)/4
	local inputRowChildren = {
		{1,"start",false},{2,"start",true},
		{3,"start",false},{4,"start",true},
		{5,"start",false},{6,"start",true},
		{7,"start",false},{8,"start",true}
	}
	local self = mod(gui.Slice(tex.Panel, nil, {2}, 0, 0, 0, w, h, 0, 0, 0, 0, {"fill", "none"}), {name = labelTxt, layer = "widgets", children = {
		mod(gui.Row(0, false, {{1,"start",false},{2,"end",true}}, 0, 0, 0, w, h, 0, 0, 0, 0, "fill"), {children = {
			mod(gui.Text(labelTxt, fnt.default, 3, -1, 0, labelW, -1, 0, -1, 0, "left", "fill"), {layer = "text"}),
			mod(gui.Row(2, false, inputRowChildren, 0, 0, 0, w/2, h, 0, 0, 0, 0, "fill"), {children = {
				mod(gui.Text("r", fnt.default, 0, -1, 0, subLabelW, 0, 0, 0, 0, "center", "fill"), {layer = "text", color = {0.5, 0.5, 0.5, 1}}),
				InputField(value, false, "input", "center", "fill", inputW, h),
				mod(gui.Text("g", fnt.default, 0, -1, 0, subLabelW, 0, 0, 0, 0, "center", "fill"), {layer = "text", color = {0.5, 0.5, 0.5, 1}}),
				InputField(value, false, "input", "center", "fill", inputW, h),
				mod(gui.Text("b", fnt.default, 0, -1, 0, subLabelW, 0, 0, 0, 0, "center", "fill"), {layer = "text", color = {0.5, 0.5, 0.5, 1}}),
				InputField(value, false, "input", "center", "fill", inputW, h),
				mod(gui.Text("a", fnt.default, 0, -1, 0, subLabelW, 0, 0, 0, 0, "center", "fill"), {layer = "text", color = {0.5, 0.5, 0.5, 1}}),
				InputField(value, false, "input", "center", "fill", inputW, h),
			}})
		}})
	}, color = {0.75, 0.75, 0.75, 1}, ruuInit = ruuInit, setValue = setValue, updateScroll = updateScroll, final = final})
	return self
end

return _new
