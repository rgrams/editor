
local script = {}

local collision = require "viewport.viewport-collision"

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

local function drawObjectsParentLines(objects, scale)
	for i,object in ipairs(objects) do
		if object.parent ~= object.tree then
			love.graphics.push()
			applyObjectTransform(object.parent)
			local x, y = object.pos.x * 0.93, object.pos.y * 0.93
			love.graphics.line(0, 0, x, y)
			local vx, vy = vector.normalize(-x, -y)
			local length, angle = SETTINGS.parentLineArrowLength, SETTINGS.parentLineArrowAngle
			vx, vy = vx * length * scale, vy * length * scale
			local x2, y2 = vector.rotate(vx, vy, angle)
			local x3, y3 = vector.rotate(vx, vy, -angle)
			love.graphics.line(x2+x, y2+y, x, y, x3+x, y3+y)
			love.graphics.pop()
		end
		if object.children then
			drawObjectsParentLines(object.children, scale)
		end
	end
end

function script.draw(self)
	local viewport = scene:get("/root/mainColumn/mainRow/viewport")
	local hoveredObj = viewport.hoveredObj
	local selection = viewport.selection
	local latest = selection.history[#selection.history]
	local cam = Camera.current

	local scale = 1 / Camera.current.zoom
	love.graphics.setLineWidth(scale * SETTINGS.highlightLineWidth)
	love.graphics.setColor(SETTINGS.selectedHighlightColor)

	local camtlx, camtly = cam:screenToWorld(cam.vp.x, cam.vp.y)
	local cambrx, cambry = cam:screenToWorld(cam.vp.x + cam.vp.w, cam.vp.y + cam.vp.h)
	local camcx, camcy = (camtlx + cambrx)/2, (camtly + cambry)/2

	-- For selection-out-of-bounds indicators.
	local margin = SETTINGS.selectionOutOfBoundsLineMargin * scale
	local length = SETTINGS.selectionOutOfBoundsLineLength * scale

	for obj,dat in pairs(selection._) do
		local color = SETTINGS.selectedHighlightColor
		local scale = scale
		if obj == latest then
			color = SETTINGS.latestSelectedHighlightColor
			scale = scale * 3 + 0.5
		end
		love.graphics.setColor(color)

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

	love.graphics.setLineWidth(scale)
	love.graphics.setColor(SETTINGS.parenthoodLineColor)
	drawObjectsParentLines(editScene.children, scale)

	love.graphics.setLineWidth(1)
end

return script
