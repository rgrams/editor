
local script = {}

local inputManager = require "input-manager"

function script.init(self)
	Input.enable(self)
end

function script.input(self, name, value, change)
	inputManager.input(name, value, change)
end

return script
