
-- Manages an input stack.

local M = {}

local objStack = {}

function M.add(obj, pos)
	pos = pos or "top"
	if pos == "top" then
		table.insert(objStack, 1, obj) -- First on stack is the "top" - the first to get input.
	else
		table.insert(objStack, obj)
	end
end

function M.remove(obj)
	for i,v in ipairs(objStack) do
		if v == obj then
			table.remove(objStack, i)
			return
		end
	end
end

-- A custom version of obj.call that stops on the first truthy return value.
local function call(obj, funcName, ...)
	local r
	if obj[funcName] then
		r = obj[funcName](obj, ...)
		if r then  return r  end
	end
	if obj.script then
		for i,scr in ipairs(obj.script) do
			if scr[funcName] then
				r = scr[funcName](obj, ...)
				if r then  return r  end
			end
		end
	end
end

function M.mouseMoved(x, y, dx, dy)
	for i,obj in ipairs(objStack) do
		local consumed = call(obj, "mouseMoved", x, y, dx, dy)
		if consumed then  return  end
	end
end

function M.input(name, value, change)
	for i,obj in ipairs(objStack) do
		local consumed = call(obj, "input", name, value, change)
		if consumed then  return  end
	end
end

return M
