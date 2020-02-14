
local Class = require "philtre.lib.base-class"
local Selection = Class:extend()

local activeData = require "activeData"

function Selection.set(self)
	self._ = {} -- Need to separate from methods so we can iterate (by keys).
end

function Selection.add(self, enclosure)
	self._[enclosure[1]] = {dragOX = 0, draxOY = 0}

	local obj = enclosure[1]
	activeData.propertiesPanel:call("setObject", obj)

	return self, enclosure
end

-- Clear and then add - So it's one command instead of two.
function Selection.setTo(self, enclosure)
	local _,oldList = self:clear()
	self:add(enclosure)
	return self, oldList -- Undo with _set
end

function Selection.remove(self, enclosure)
	self._[enclosure[1]] = nil
	return self, enclosure
end

function Selection.toggle(self, enclosure)
	if self._[enclosure[1]] then  self:remove(enclosure)
	else  self:add(enclosure)  end
	return self, enclosure
end

function Selection.clear(self)
	local old = self._
	self._ = {}
	return self, old
end

function Selection._set(self, new) -- For undoing Selection.clear.
	local old = self._
	self._ = new
	return self, old
end

-- Methods that do not modify the command history:

function Selection.has(self, obj)
	return self._[obj]
end

function Selection.updateDragOffsets(self, sx, sy)
	local wx, wy = Camera.current:screenToWorld(sx, sy)
	for obj,data in pairs(self._) do
		data.dragOX, data.dragOY = obj._to_world.x - wx, obj._to_world.y - wy
	end
end

return Selection
