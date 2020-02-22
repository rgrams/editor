
local script = {}

function script.input(self, name, value, change)
	self.filesPanel:call("input", name, value, change)
end

return script
