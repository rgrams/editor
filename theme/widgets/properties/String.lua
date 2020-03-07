
local Base = require "theme.widgets.properties.Base"

-- { key = 1, label = "r", sizeShare = 1, type = "text" or "bool", scrollToRight = "false" }
local fields = { {} }

local function _new(labelTxt, value)
	return Base(labelTxt, value, fields)
end

return _new
