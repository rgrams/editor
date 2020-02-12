
-- Manages an input stack.

local M = {}

local objStack = {}

-- Can cause infinite loops and other wacky behavior if you modify the stack while
-- iterating through it, so delay all add-removes until the input is dealt with.
local isDuringCall = false
local delayedAddRemoves = {}

function M.add(obj, pos)
	pos = pos or "top"
	if isDuringCall then
		table.insert(delayedAddRemoves, {"add", obj, pos})
		return
	end
	if pos == "top" then
		table.insert(objStack, 1, obj) -- First on stack is the "top" - the first to get input.
	else
		table.insert(objStack, obj)
	end
end

function M.remove(obj)
	if isDuringCall then
		table.insert(delayedAddRemoves, 1, {"remove", obj}) -- List in reverse order so we can remove them as we go.
		return
	end
	for i,v in ipairs(objStack) do
		if v == obj then
			table.remove(objStack, i)
			return
		end
	end
end

function doDelayedCalls()
	for i=#delayedAddRemoves,1,-1 do
		local v = delayedAddRemoves[i]
		if v[1] == "add" then
			M.add(v[2], v[3])
		else
			M.remove(v[2])
		end
		delayedAddRemoves[i] = nil
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
	isDuringCall = true
	for i,obj in ipairs(objStack) do
		local consumed = call(obj, "mouseMoved", x, y, dx, dy)
		if consumed then  break  end
	end
	isDuringCall = false
	doDelayedCalls()
end

function M.input(name, value, change)
	isDuringCall = true
	shouldRedraw = true
	for i,obj in ipairs(objStack) do
		local consumed = call(obj, "input", name, value, change)
		if consumed then  break  end
	end
	isDuringCall = false
	doDelayedCalls()
end

return M
