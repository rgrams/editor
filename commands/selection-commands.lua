
local activeData = require "activeData"

local function add(self, enclosure)
	local obj = enclosure[1]
	self._[obj] = {dragOX = 0, draxOY = 0}
	self.latest = obj
	activeData.propertiesPanel:call("updateSelection", self._)
	return self, enclosure
end

local function remove(self, enclosure)
	self._[enclosure[1]] = nil
	if self.latest == enclosure[1] then  self.latest = nil  end
	activeData.propertiesPanel:call("updateSelection", self._)
	return self, enclosure
end

local function clear(self)
	local oldList, oldLatest = self._, self.latest
	self._ = {}
	self.latest = nil
	activeData.propertiesPanel:call("updateSelection", self._)
	return self, oldList, oldLatest
end

-- Clear and then add - So it's one command instead of two.
local function setTo(self, enclosure)
	local _, oldList, oldLatest = clear(self)
	add(self, enclosure)
	return self, oldList, oldLatest -- Undo with _set
end

local function toggle(self, enclosure)
	if self._[enclosure[1]] then  remove(self, enclosure)
	else  add(self, enclosure)  end
	return self, enclosure
end

local function _set(self, new, newLatest) -- For undoing clear().
	local old, oldLatest = self._, self.latest
	self._ = new
	self.latest = newLatest
	activeData.propertiesPanel:call("updateSelection", self._)
	return self, old, oldLatest
end

return {
	addToSelection = { add, remove },
	removeFromSelection = { remove, add },
	toggleObjSelection = { toggle, toggle },
	clearSelection = { clear, _set },
	setSelectionTo = { setTo, _set }
}
