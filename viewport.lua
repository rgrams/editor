
local script = {}

local inputManager = require "input-manager"

function script.init(self)
	inputManager.add(self, "bottom")
end

function script.input(self, name, value, change)
end

return script
