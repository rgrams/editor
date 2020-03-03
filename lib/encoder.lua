
-- Encodes an object or tree of objects into a lua module that can be
-- __called directly to recreate the object(s).

local M = {}

local objToString = require "philtre.lib.object-to-string"
local objProp = require "object.object-properties"

local function quotifyString(s)
	return "\"" .. s .. "\""
end

local function stringifyTable(t)
	local _t = {unpack(t)}
	for i,v in ipairs(_t) do
		if type(v) == "string" then  _t[i] = quotifyString(v)  end
	end
	return "{" .. table.concat(_t, ", ") .. "}"
end

local function encodeObject(obj, indentLevel)
	indentLevel = indentLevel or 0
	local indent = string.rep("\t", indentLevel)
	if not obj then  return indent .. "nil"  end

	local className = obj.className
	local constructArgs = objProp.constructArgs[className]
	local s = className .. "("
	local args = {}
	-- Get values of constructor args from the object.
	for i,v in ipairs(constructArgs) do
		local key, subKey = unpack(v)
		local defaultVal = objProp.getDefault(className, key, subKey)
		local val = objProp.getValue(obj, key, subKey)
		if objProp.areValuesEqual(val, defaultVal) then  val = "nil"
		elseif type(val) == "table" then  val = stringifyTable(val)
		elseif type(val) == "string" then  val = quotifyString(val)  end
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

	-- Make a list of extra properties to mod() onto the object.
	local isConstructArg = objProp.isConstructArg[className]
	local modKeys = objProp.modKeys
	local mods
	for k,v in pairs(obj) do
		if modKeys[k] and not isConstructArg[k] then
			if k == "children" and #v < 1 then
				-- Ignore child list if it's empty (if it had a child and it was removed).
			elseif k == "name" and v == className then
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

local prefix = "\nlocal function new()\n\tlocal self = "

local suffix = "\n\treturn self\nend\n\nreturn new\n"

function M.encode(root)
	local str = encodeObject(root, 1)
	str = prefix .. string.sub(str, 2) .. suffix -- cut off first indent, it's already in the prefix.
	return str
end

return M
