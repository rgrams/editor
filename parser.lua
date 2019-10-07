
local M = {}

local objToString = require "philtre.lib.object-to-string"
local classProperties = require "class-properties"
local classConstructorArgs = require "class-constructor-args"

local function getObjVal(obj, key, subKey)
	if subKey then  return obj[key][subKey]
	else  return obj[key]  end
end

local function encodeObject(obj)
	local class = obj.className
	local conArgs = classConstructorArgs[class] or classConstructorArgs.Object
	local s = class .. "("
	local args = {}
	-- Get values of constructor args from the object.
	for i,v in ipairs(conArgs) do
		local key, defaultVal, subKey = v[1], v[2], v[3]
		local val = getObjVal(obj, key, subKey)
		if val == defaultVal then  val = "nil"  end -- If they are the default value
		table.insert(args, val)
	end
	-- Remove excess args at the end that are default values.
	for i=#args,1,-1 do
		local v = args[i]
		if v == "nil" and not args[i+1] then
			args[i] = nil
		end
	end
	-- Add args to string.
	for i,v in ipairs(args) do
		s = s .. v
		if i ~= #args then  s = s .. ", "  end
	end
	s = s .. ")"

	local conArgKeys = classConstructorArgs.keys[class] or classConstructorArgs[key].Object
	local modKeys = classConstructorArgs.modKeys
	local mods
	for k,v in pairs(obj) do
		if not conArgKeys[k] and modKeys[k] then
			if k == "name" and v == class then
				-- Don't include name if it hasn't changed.
			else
				mods = mods or {}
				mods[k] = v
			end
		end
	end
	if mods then
		s = "mod(" .. s .. ", { "
		for k,v in pairs(mods) do
			s = s .. k .. " = " .. objToString(v) .. ", "
		end
		s = string.sub(s, 1, -3) .. " })"
	end
	print(s)
end

function M.encode(root)
	encodeObject(root)
end

function M.decode(text)
end

return M
