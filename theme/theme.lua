
local basePath = (...):gsub('[^%.]+$', '')
local Class = require("ruu.base widgets.base-class")

local M = {}

local tex = require(basePath .. "textures")

--##############################  BUTTON  ##############################
local Button = Class:extend()
M.Button = Button

local function setValue(self, val)
	local c = self.color
	c[1], c[2], c[3] = val, val, val
end

function Button.init(self)
	if self.label then  setValue(self.label, 0.75)  end

	local draw = self.draw
	self.draw = function(self)
		draw(self)
		if self.isFocused then
			local w, h = self.w, self.h
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle("line", -w/2, -h/2, w, h, 4, 4, 3)
		end
	end
end

function Button.hover(self)
	if self.label then  setValue(self.label, 1)  end
	self.image = tex.Button_Hovered
end

function Button.unhover(self)
	if self.label then  setValue(self.label, 0.75)  end
	self.image = tex.Button_Normal
end

function Button.focus(self)
end

function Button.unfocus(self)
end

function Button.press(self)
	if self.label then  self.label.pos.y = self.label.pos.y + 1  end
	self.image = tex.Button_Pressed
end

function Button.release(self)
	if self.label then  self.label.pos.y = self.label.pos.y - 1  end
	self.image = self.isHovered and tex.Button_Hovered or tex.Button_Normal
end

--##############################  TOGGLE-BUTTON  ##############################
local ToggleButton = Button:extend()
M.ToggleButton = ToggleButton

function ToggleButton.init(self)
	ToggleButton.super.init(self)
	self.check = gui.Sprite(tex.ToggleButtonCheck)
	self.check.visible = self.isChecked
	scene:add(self.check, self)
end

function ToggleButton.hover(self)
	self.image = tex.ToggleButton_Hovered
end

function ToggleButton.unhover(self)
	self.image = tex.ToggleButton_Normal
end

function ToggleButton.press(self)
	self.image = tex.ToggleButton_Pressed
end

function ToggleButton.release(self)
	self.image = self.isHovered and tex.ToggleButton_Hovered or tex.ToggleButton_Normal
	self.check:setVisible(self.isChecked)
end

--##############################  RADIO-BUTTON  ##############################
local RadioButton = Button:extend()
M.RadioButton = RadioButton

function RadioButton.init(self)
	RadioButton.super.init(self)
	local img = self.isChecked and tex.RadioButton_Checked or tex.RadioButton_Unchecked
	self.check = gui.Sprite(img, 0, 0, 0, 1, 1, nil, -1, 0, -1, 0)
	scene:add(self.check, self)
end

function RadioButton.release(self)
	RadioButton.super.release(self)
	self.check.image = self.isChecked and tex.RadioButton_Checked or tex.RadioButton_Unchecked
end


function RadioButton.uncheck(self)
	self.check.image = tex.RadioButton_Unchecked
end

--##############################  SLIDER - BAR  ##############################
local SliderBar = Button:extend()
M.SliderBar = SliderBar

function SliderBar.hover(self)
	self.image = tex.SliderBar_Hovered
end
function SliderBar.unhover(self)
	self.image = tex.SliderBar_Normal
end

function SliderBar.focus(self)  end
function SliderBar.unfocus(self)  end

function SliderBar.press(self)
	self.image = tex.SliderBar_Pressed
end

function SliderBar.release(self)
	self.image = self.isHovered and tex.SliderBar_Hovered or tex.SliderBar_Normal
end

--##############################  SLIDER - HANDLE  ##############################
local SliderHandle = Button:extend()
M.SliderHandle = SliderHandle

function SliderHandle.init(self)
	SliderHandle.super.init(self)
	SliderHandle.drag(self)
end

function SliderHandle.drag(self)
	-- self.angle = self.fraction * math.pi
end

function SliderHandle.focus(self)
end

function SliderHandle.unfocus(self)
end

--##############################  SCROLL-AREA  ##############################
local ScrollArea = Button:extend()
M.ScrollArea = ScrollArea

function ScrollArea.init(self)  end
function ScrollArea.hover(self)  end
function ScrollArea.unhover(self)  end
function ScrollArea.focus(self)  end
function ScrollArea.unfocus(self)  end
function ScrollArea.press(self)  end
function ScrollArea.release(self)  end

--##############################  INPUT-FIELD  ##############################
local InputField = Button:extend()
M.InputField = InputField

function InputField.setText(self, isPlaceholder)
	local alpha = isPlaceholder and 0.5 or 1
	self.textObj.color[4] = alpha
end

--##############################  PANEL  ##############################
local Panel = Class:extend()
M.Panel = Panel

function Panel.init(self)  end
function Panel.hover(self)  end
function Panel.unhover(self)  end
function Panel.focus(self)  end
function Panel.unfocus(self)  end
function Panel.press(self)  end
function Panel.release(self)  end

--##############################  RESIZE-HANDLE  ##############################
local ResizeHandle = Class:extend()
M.ResizeHandle = ResizeHandle

function ResizeHandle.init(self)  end

function ResizeHandle.hover(self)
	love.mouse.setCursor(love.mouse.getSystemCursor("sizewe"))
end

function ResizeHandle.unhover(self)
	love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
end

function ResizeHandle.focus(self)  end
function ResizeHandle.unfocus(self)  end
function ResizeHandle.press(self)  end
function ResizeHandle.release(self)  end

--##############################  FILE-WIDGET  ##############################
local FileWidget = Button:extend()
M.FileWidget = FileWidget

function FileWidget.init(self)
	if self.label then  setValue(self.label, 0.75)  end

	local draw = self.draw
	self.draw = function(self)
		draw(self)
		if self.isFocused then
			local w, h = self.w, self.h
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle("line", -w/2, -h/2, w, h)
		end
	end
end

function FileWidget.hover(self)
	if self.label then  setValue(self.label, 1)  end
	self.image = tex.Panel_Hovered
end

function FileWidget.unhover(self)
	if self.label then  setValue(self.label, 0.75)  end
	self.image = tex.Panel
end

function FileWidget.press(self)
	if self.label then  self.label.pos.y = self.label.pos.y + 1  end
	self.image = tex.Panel_Pressed
end

function FileWidget.release(self)
	if self.label then  self.label.pos.y = self.label.pos.y - 1  end
	self.image = self.isHovered and tex.Panel_Hovered or tex.Panel
end

return M
