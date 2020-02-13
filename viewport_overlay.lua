
local script = {}

local collision = require "viewport-collision"

local function applyObjectTransform(obj)
	-- love.graphics.origin()
	local m = obj._to_world
	local th, sx, sy, kx, ky = matrix.parameters(m)
	love.graphics.translate(m.x, m.y)
	love.graphics.rotate(th)
	love.graphics.scale(sx, sy)
	love.graphics.shear(kx, ky)
end

local function drawObjOutline(obj, scale)
	love.graphics.push()
	applyObjectTransform(obj)

	local w2, h2 = collision.getExtents(obj)
	w2, h2 = w2 + scale, h2 + scale
	love.graphics.rectangle("line", -w2, -h2, w2*2, h2*2)

	love.graphics.pop()
end

function script.draw(self)
	local viewport = scene:get("/root/mainColumn/mainRow/viewport")
	local hoverList = viewport.hoverList
	local selection = viewport.selection

	local scale = 2 / Camera.current.zoom
	love.graphics.setLineWidth(scale)

	love.graphics.setColor(SETTINGS.selectedHighlightColor)
	for obj,dat in pairs(selection) do
		drawObjOutline(obj, scale)
	end

	love.graphics.setColor(SETTINGS.hoverHighlightColor)
	for i,v in ipairs(hoverList) do
		local obj = v[1]
		drawObjOutline(obj, scale)
	end
	
	love.graphics.setLineWidth(1)
end

return script
