
-- Encodes an object or tree of objects into a lua module that can be
-- __called directly to recreate the object(s).

local M = {}

local objToString = require "philtre.lib.object-to-string"
local classProperties = require "class-properties"
local classConstructorArgs = require "class-constructor-args"

local function getObjVal(obj, key, subKey)
	if subKey then  return obj[key][subKey]
	else  return obj[key]  end
end

local function encodeObject(obj, indentLevel)
	indentLevel = indentLevel or 0
	local indent = string.rep("\t", indentLevel)

	local class = obj.className
	local constructArgs = classConstructorArgs[class] or classConstructorArgs.Object
	local s = class .. "("
	local args = {}
	-- Get values of constructor args from the object.
	for i,v in ipairs(constructArgs) do
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

	local conArgKeys = classConstructorArgs.keys[class] or classConstructorArgs.keys.Object
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
		if mods.name then
			s = s .. "name = \"" .. mods.name .. "\", "
		end
		if mods._script then
			print("has script")
			s = s .. "script = { " .. table.concat(mods._script, ", ") .. "}, "
		end
		if mods.children then
			s = s .. "children = {\n"
			for i,child in ipairs(mods.children) do
				s = s .. encodeObject(child, indentLevel + 1) .. ",\n"
			end
			s = string.sub(s, 1, -3) .. "\n" .. indent .. "}, "
		end
		s = string.sub(s, 1, -3) .. " })"
	end
	s = indent .. s
	return s
end

local prefix = "\nlocal function new(_)\n"

local suffix = "\nend\n\nreturn setmetatable({}, { __call = new })\n"

function M.encode(root)
	local str = encodeObject(root, 1)
	str = prefix .. str .. suffix
	print(str)
	return str
end

return M
