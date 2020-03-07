
local Base = require "theme.widgets.properties.Base"

-- { key = 1, label = "r", sizeShare = 1, type = "text" or "bool", scrollToRight = "false" }
local fields = {
	{ key = 1, label = "r" },
	{ key = 2, label = "g" },
	{ key = 3, label = "b" },
	{ key = 4, label = "a" },
}

local function _new(labelTxt, value)
	return Base(labelTxt, value, fields)
end

return _new
