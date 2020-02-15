
local activeData = require "activeData"

local function add(self, enclosure)
	local obj = enclosure[1]
	self._[obj] = {dragOX = 0, draxOY = 0}
	activeData.propertiesPanel:call("setObject", obj)
	return self, enclosure
end

local function remove(self, enclosure)
	self._[enclosure[1]] = nil
	return self, enclosure
end

local function clear(self)
	local oldList = self._
	self._ = {}
	return self, oldList
end

-- Clear and then add - So it's one command instead of two.
local function setTo(self, enclosure)
	local _, oldList = clear(self)
	add(self, enclosure)
	return self, oldList -- Undo with _set
end

local function toggle(self, enclosure)
	if self._[enclosure[1]] then  remove(self, enclosure)
	else  add(self, enclosure)  end
	return self, enclosure
end

local function _set(self, new) -- For undoing clear().
	local old = self._
	self._ = new
	return self, old
end

return {
	addToSelection = { add, remove },
	removeFromSelection = { remove, add },
	toggleObjSelection = { toggle, toggle },
	clearSelection = { clear, _set },
	setSelectionTo = { setTo, _set }
}
