
local Number = require "theme.widgets.properties.Number"
local Color = require "theme.widgets.properties.Color"
local Font = require "theme.widgets.properties.Font"
local Image = require "theme.widgets.properties.Image"
local Quad = require "theme.widgets.properties.Quad"
local String = require "theme.widgets.properties.String"

local M = {
	bool = Number,
	color = Color,
	font = Font,
	image = Image,
	number = Number,
	quad = Quad,
	string = String,
	vector2 = Number,
}

return M