
local script = {}

local collision = require "viewport-collision"

local function applyObjectTransform(obj)
	-- Don't need to reset to origin, overlay obj is at 0, 0 and drawn inside camera transform.
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
	local pad = SETTINGS.highlightPadding
	w2, h2 = w2 + scale + pad, h2 + scale + pad
	love.graphics.rectangle("line", -w2, -h2, w2*2, h2*2)

	love.graphics.pop()
end

local function intersectLineWithBounds(ax, ay, cx, cy, tlx, tly, brx, bry)
	local vx, vy = vector.normalize(cx - ax, cy - ay) -- Normalized line vector.
	local x, y = ax, ay -- intersect point.
	if ax < tlx or ax > brx then
		local edgeX = math.clamp(ax, tlx, brx)
		local xOutDist = edgeX - ax
		y = ay + xOutDist * vy
	end
	if ay < tly or ay > bry then
		local edgeY = math.clamp(ay, tly, bry)
		local yOutDist = edgeY - ay
		x = ax + yOutDist * vx
	end
	x, y = math.clamp(x, tlx, brx), math.clamp(y, tly, bry)
	return x, y, vx, vy
end

function script.draw(self)
	local viewport = scene:get("/root/mainColumn/mainRow/viewport")
	local hoveredObj = viewport.hoveredObj
	local selection = viewport.selection
	local cam = Camera.current

	local scale = 1 / Camera.current.zoom
	love.graphics.setLineWidth(scale * SETTINGS.highlightLineWidth)

	local camtlx, camtly = cam:screenToWorld(cam.vp.x, cam.vp.y)
	local cambrx, cambry = cam:screenToWorld(cam.vp.x + cam.vp.w, cam.vp.y + cam.vp.h)
	local camcx, camcy = (camtlx + cambrx)/2, (camtly + cambry)/2

	-- For selection-out-of-bounds indicators.
	local margin = SETTINGS.selectionOutOfBoundsLineMargin * scale
	local length = SETTINGS.selectionOutOfBoundsLineLength * scale

	love.graphics.setColor(SETTINGS.selectedHighlightColor)
	for obj,dat in pairs(selection) do
		drawObjOutline(obj, scale)

		local wx, wy = obj._to_world.x, obj._to_world.y
		if wx < camtlx or wx > cambrx or wy < camtly or wy > cambry then
			local hitx, hity, vx, vy = intersectLineWithBounds(wx, wy, camcx, camcy, camtlx, camtly, cambrx, cambry)
			hitx, hity = hitx + vx * margin, hity + vy * margin
			local endx, endy = hitx + vx * length, hity + vy * length
			love.graphics.line(hitx, hity, endx, endy)
		end
	end

	if hoveredObj then
		love.graphics.setColor(SETTINGS.hoverHighlightColor)
		drawObjOutline(hoveredObj, scale)
	end

	love.graphics.setLineWidth(1)

end

return script
