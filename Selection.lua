
local function getEnclosureList(self)
	local enclosureList = {}
	for obj,_ in pairs(self._) do
		local enclosure = obj[PRIVATE_KEY]
		table.insert(enclosureList, enclosure)
	end
	return enclosureList
end

local function new()
	return {
		_ = {},  -- Separate content from reference.
		getEnclosureList = getEnclosureList
	}
end

return new
