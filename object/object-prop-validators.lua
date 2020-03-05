
local M = {}

function M.vector2(val)
	return type(val) == "number"
end

function M.number(val)
	return type(val) == "number"
end

function M.image(val)
	local success, errorMsg = pcall(new.image, val)
	return success, errorMsg
end

function M.color(val)
end

function M.string(val)
	return type(val) == "string"
end

function M.font(val)
end

function M.quad(val)
end

function M.bool(val)
	return type(val) == "boolean"
end


return M
