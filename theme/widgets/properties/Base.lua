
local tex = require "theme.textures"
local fnt = require "theme.fonts"
local InputField = require "theme.widgets.InputField"

local function ruuInit(self, ruu, key, subKey, valType, callback)
	self.ruu = ruu
	self.ruuWidgets = {}
	local inputRow = self.children[1].children[2]
	for i,field in ipairs(inputRow.children) do
		if not field:is(gui.Text) then
			local mask = field.children[1]
			local text = mask.children[1]
			local toRight = field.scrollToRight
			ruu:makeInputField(field, text, mask, true, nil, callback, toRight)
			if subKey then  field._propSubKey = subKey  end -- Otherwise set in constructor.
			field._propKey = key
			field._propName, field._valType = self.name, valType
			table.insert(self.ruuWidgets, field)
		end
	end
end

local function setValue(self, value)
	if #self.ruuWidgets == 1 then
		self.ruuWidgets[1]:setText(tostring(value))
	else
		for i,field in ipairs(self.ruuWidgets) do
			field:setText(tostring(value[field._propSubKey]))
		end
	end
end

local function updateScroll(self)
	for i,v in ipairs(self.ruuWidgets) do  v:updateScroll()  end
end

local function final(self)
	for i,v in ipairs(self.ruuWidgets) do  self.ruu:destroyWidget(v)  end
end

local function newSubLabel(txt, w)
	local label = mod(
		gui.Text(txt, fnt.default, 0, -1, 0, w, 0, 0, 0, 0, "center", "fill"),
		{ layer = "text", color = {0.5, 0.5, 0.5, 1} }
	)
	return label
end

local function _new(labelTxt, value, fields)
	assert(labelTxt, "PropertyWidget - can't create without a label name.")
	local w, h = 200, 24
	local font = new.font(unpack(fnt.default))
	local labelW = font:getWidth(labelTxt) + 6
	labelW = math.max(labelW, w/3)

	-- Add up total width shares.
	local totalWShares = 0
	for i,data in ipairs(fields) do
		totalWShares = totalWShares + (data.sizeShare or 1)
	end
	local shareW = w/2 / totalWShares
	-- Create fields.
	local children = {}
	local rowChildren = {}
	for i,data in ipairs(fields) do
		-- { key = 1, label = "r", sizeShare = 1, type = "text" or "bool", scrollToRight = "false" }
		if data.label then
			local labelW = font:getWidth(data.label) * 1.3
			local label = newSubLabel(data.label, labelW)
			table.insert(children, label)
			table.insert(rowChildren, { label, "start", false })
		end
		local w = (data.sizeShare or 1) * shareW
		local val = tostring(data.key and value[data.key] or value)
		local field = InputField(val, nil, "input", "center", nil, w, h)
		field.scrollToRight = data.scrollToRight
		field._propSubKey = data.key
		table.insert(children, field)
		table.insert(rowChildren, { field, "start", "true" })
	end

	local self = mod(gui.Slice(tex.Panel, nil, {2}, 0, 0, 0, w, h, 0, 0, 0, 0, {"fill", "none"}), {name = labelTxt, layer = "widgets", children = {
		mod(gui.Row(0, false, {{1,"start",false},{2,"end",true}}, 0, 0, 0, w, h, 0, 0, 0, 0, "fill"), {children = {
			-- Main label.
			mod(gui.Text(labelTxt, fnt.default, 3, -1, 0, labelW, -1, 0, -1, 0, "left", "fill"), {layer = "text"}),
			-- Row of InputFields and possibly sub-labels
			mod(gui.Row(1, false, rowChildren, 0, 0, 0, w/2, h, 0, 0, 0, 0, "fill"), {children = children})
		}})
	}, color = {0.75, 0.75, 0.75, 1}, ruuInit = ruuInit, setValue = setValue, updateScroll = updateScroll, final = final})
	return self
end

return _new
