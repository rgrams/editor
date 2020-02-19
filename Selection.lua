
local function getEnclosureList(self)
	local enclosureList = {}
	for enclosure,_ in pairs(self._) do
		table.insert(enclosureList, enclosure)
	end
	return enclosureList
end

local function new()
	return {
		_ = {}, -- Separate content from reference, allow methods & properties.
		history = {},
		getEnclosureList = getEnclosureList
	}
end

return new
