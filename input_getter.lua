
local script = {}

local inputManager = require "lib.input-manager"

function script.init(self)
	Input.enable(self)
end

function script.input(self, name, value, change)
	inputManager.input(name, value, change)
end

return script
