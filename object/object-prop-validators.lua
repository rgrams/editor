
local M = {}

local setget = require "object.object-prop-set-getters"
local projectPath, displayPath = setget.projectPath, setget.displayPath

function M.vector2(val)
	return type(val) == "number"
end

function M.number(val)
	return type(val) == "number"
end

function M.image(val)
	local success, errorMsg = pcall(new.image, projectPath(val))
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
		local path, size = unpack(val)
		local success, errorMsg = pcall(new.font, projectPath(path), size)
		return success, errorMsg
	elseif subKey == 2 then
		return type(val) == "number"
	elseif subKey == 1 then
		return love.filesystem.getInfo(projectPath(val))
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
