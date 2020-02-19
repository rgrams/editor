
local activeData = require "activeData"

local function add(self, enclosure)
	self._[enclosure] = {dragOX = 0, draxOY = 0}
	table.insert(self.history, enclosure)
	-- activeData.propertiesPanel:call("updateSelection", self._)
	return self, enclosure
end

local function remove(self, enclosure)
	if not self._[enclosure] then  return  end -- Object wasn't selected anyway.
	self._[enclosure] = nil
	for i=#self.history,1,-1 do
		if self.history[i] == enclosure then
			table.remove(self.history, i)
			break
		end
	end
	-- activeData.propertiesPanel:call("updateSelection", self._)
	return self, enclosure
end

local function clear(self)
	local oldList, oldHistory = self._, self.history
	self._, self.history = {}, {}
	-- activeData.propertiesPanel:call("updateSelection", self._)
	return self, oldList, oldHistory
end

-- Clear and then add - So it's one command instead of two.
local function setTo(self, enclosure)
	local _, oldList, oldHistory = clear(self)
	add(self, enclosure)
	return self, oldList, oldHistory -- Undo with _set
end

local function toggle(self, enclosure)
	if self._[enclosure] then  remove(self, enclosure)
	else  add(self, enclosure)  end
	return self, enclosure
end

local function _set(self, new, newHistory) -- For undoing clear().
	local old, oldHistory = self._, self.history
	self._ = new
	self.history = newHistory
	-- activeData.propertiesPanel:call("updateSelection", self._)
	return self, old, oldHistory
end

return {
	addToSelection = { add, remove },
	removeFromSelection = { remove, add },
	toggleObjSelection = { toggle, toggle },
	clearSelection = { clear, _set },
	setSelectionTo = { setTo, _set }
}
