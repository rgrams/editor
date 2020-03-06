
local function debugDraw_Object(self)
	love.graphics.setBlendMode('alpha')
	local r = SETTINGS.ObjectHitRadius
	love.graphics.setColor(SETTINGS.xAxisColor)
	love.graphics.line(0, 0, r, 0)
	love.graphics.setColor(SETTINGS.yAxisColor)
	love.graphics.line(0, 0, 0, -r)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle('line', -r, -r, r*2, r*2)
	love.graphics.circle('line', 0, 0, 0.5, 4)
end

function Object.debugDraw(self, layer)
	if self.tree then
		self.tree.draw_order:addFunction(layer, self._to_world, debugDraw_Object, self)
	end
end

local function debugDraw_Sprite(self)
	love.graphics.setBlendMode('alpha')
	local r = SETTINGS.ObjectHitRadius
	love.graphics.setColor(SETTINGS.xAxisColor)
	love.graphics.line(0, 0, r, 0)
	love.graphics.setColor(SETTINGS.yAxisColor)
	love.graphics.line(0, 0, 0, -r)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.circle('line', 0, 0, 0.5, 4)
end

function Sprite.debugDraw(self, layer)
	if self.tree then
		self.tree.draw_order:addFunction(layer, self._to_world, debugDraw_Sprite, self)
	end
end
Quad.debugDraw = Sprite.debugDraw

local function debugDraw_World(self)
	love.graphics.setBlendMode('alpha')
	local r = SETTINGS.ObjectHitRadius
	love.graphics.setColor(SETTINGS.xAxisColor)
	love.graphics.line(0, 0, r, 0)
	love.graphics.setColor(SETTINGS.yAxisColor)
	love.graphics.line(0, 0, 0, -r)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.circle('line', 0, 0, 0.5, 4)
	love.graphics.circle('line', 0, 0, r*3)
end

function World.debugDraw(self, layer)
	if self.tree then
		self.tree.draw_order:addFunction(layer, self._to_world, debugDraw_World, self)
	end
end
