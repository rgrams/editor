
local M = {}

local function shallowCopy(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
end

M.Object = {
	{"pos", 0, "x"}, {"pos", 0, "y"}, {"angle", 0},
	{"sx", 1}, {"sy", 1}, {"kx", 0}, {"ky", 0}
}

local keys = {}
for className,data in pairs(M) do
	local classKeys = {}
	keys[className] = classKeys
	for i,v in ipairs(data) do
		classKeys[v[1]] = true
	end
end
M.keys = keys

M.modKeys = {
	name = true, children = true, script = true
}

return M
