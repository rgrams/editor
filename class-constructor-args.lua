
-- Stores a list of class constructor orguments for each object class.

--    Has the information needed to get each argument from an existing
--    object, so a constructor call can be encoded to recreate that object.
--        - The argument's key name on the object.
--        - The default value of the argument.
--        - The property sub-key, if the value is in a table on the object.

local M = {}

local function shallowCopy(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
end

M.Object = {
	-- key, default value, sub-key
		-- sub-key is used if the argument is in a table on the object (like x and y pos).
	{"pos", 0, "x"}, {"pos", 0, "y"}, {"angle", 0},
	{"sx", 1}, {"sy", 1}, {"kx", 0}, {"ky", 0}
}

--[[

M.Sprite = {
	image, -- ...this gets more complicated...
	{"pos", 0, "x"}, {"pos", 0, "y"}, {"angle", 0},
	{"sx", 1}, {"sy", 1},
	{"color", 1, 1}, {"color", 1, 2}, {"color", 1, 3}, {"color", 1, 4},
	{"ox", 0.5}, {"oy", 0.5} -- Can be input as strings ("center", etc.), but keep as fractions.
	{"kx", 0}, {"ky", 0}
}

M.Text = {
	-- How to get font filename and size?
}

--]]

-- Create dictionaries of argument keys for each class, so properties on
-- an object can be quickly checked to see if they go into the constructor,
-- or if they should be added on afterward.
local keys = {}
for className,classArgs in pairs(M) do
	local classKeys = {}
	keys[className] = classKeys
	for i,argSpecs in ipairs(classArgs) do
		local argName = argSpecs[1]
		classKeys[argName] = true
	end
end
M.keys = keys

-- Possible property names to mod() onto an object.
-- If a object's property is not in M.keys or M.modKeys, then it is ignored by the encoder.
M.modKeys = {
	name = true, children = true, _script = true
}

return M
