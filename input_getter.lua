
local script = {}

local inputStack = require "lib.input-stack"

function script.init(self)
	Input.enable(self)
end

function script.input(self, name, value, change)
	inputStack.input(name, value, change)
end

return script
