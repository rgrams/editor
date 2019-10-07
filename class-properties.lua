
local M = {}

local function shallowCopy(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
end

M.Object = { "name", "path", "visible", "pos", "angle", "sx", "sy" }

return M
