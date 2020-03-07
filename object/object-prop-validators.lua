
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
	return type(val) == "number"
end

function M.string(val)
	return type(val) == "string"
end

function M.font(val, subKey)
	if not subKey then
		local success, errorMsg = pcall(new.font, unpack(val))
		return success, errorMsg
	elseif subKey == 2 then
		return type(val) == "number"
	elseif subKey == 1 then
		return love.filesystem.getInfo(val)
	end
end

function M.quad(val, subKey)
	if subKey then  return type(val) == "number"
	else  return type(val) == "table" and #val >= 4  end
end

function M.bool(val)
	return type(val) == "boolean"
end


return M
