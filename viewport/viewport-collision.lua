
local M = {}

local extents = {
	Object = function(obj)
		return SETTINGS.ObjectHitRadius, SETTINGS.ObjectHitRadius
	end,
	Sprite = function(obj)
		local w, h = obj.image:getDimensions()
		return w/2, h/2
	end,
	Quad = function(obj)
		return obj.w/2, obj.h/2
	end,
	World = function(obj)
		local r = SETTINGS.ObjectHitRadius * 3
		return r, r
	end,
}

local function getExtents(obj)
	local getter = extents[obj.className] or extents["Object"]
	return getter(obj)
end
M.getExtents = getExtents

function M.hitCheckObj(obj, x, y)
	local lx, ly = obj:toLocal(x, y)
	local w2, h2 = M.getExtents(obj)
	if lx > -w2 and lx < w2 and ly > -h2 and ly < h2 then
		local dist = math.sqrt(lx*lx + ly*ly)
		return dist
	end
end

return M
