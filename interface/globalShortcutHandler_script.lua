
-- Gets input ahead of Ruu and handles global shortcuts.

local script = {}

local inputStack = require "lib.input-stack"
local activeData = require "activeData"

function script.init(self)
	inputStack.add(self)
end

return script
