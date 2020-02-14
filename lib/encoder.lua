
-- Encodes an object or tree of objects into a lua module that can be
-- __called directly to recreate the object(s).

local M = {}

local objToString = require "philtre.lib.object-to-string"
local classConstructorArgs = require "object.class-constructor-args"

local function stringifyTable(t)
	return "{" .. table.concat(t, ", ") .. "}"
end

local function getObjVal(obj, key, subKey)
	if subKey then  return obj[key][subKey]
	else  return obj[key]  end
end

local function areEqual(a, b)
	if a == b then  return true  end
	if type(a) == "table" and type(b) == "table" then
		for k,v in pairs(a) do
			if b[k] ~= v then  return  end
		end
		return true
	end
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
		local key, defaultVal, subKey, getterFunc = unpack(v)
		local getterFunc = getterFunc or getObjVal
		local val = getterFunc(obj, key, subKey)
		if areEqual(val, defaultVal) then  val = "nil"
		elseif type(val) == "table" then  val = stringifyTable(val)  end
		table.insert(args, val)
	end
	-- Remove excess args at the end that are default values.
	for i=#args,1,-1 do
		local v = args[i]
		if v == "nil" and not args[i+1] then
			args[i] = nil
		end
	end
	-- Add args list to string.
	s = s .. table.concat(args, ", ") .. ")"

	local conArgKeys = classConstructorArgs.keys[class] or classConstructorArgs.keys.Object
	local modKeys = classConstructorArgs.modKeys
	local mods
	for k,v in pairs(obj) do
		if not conArgKeys[k] and modKeys[k] then
			if k == "name" and v == class then
				-- Don't include name if it hasn't changed.
			elseif k == "children" and #v < 1 then
				-- Forget child list if it's empty (if it had a child and it was removed).
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
