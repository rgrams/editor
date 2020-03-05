
local M = {}

local Button = require "theme.widgets.Button"

function M.newScene(self, sceneName)
	print("TabBar.newScene "..tostring(sceneName))
	local button = Button(sceneName, 0, 0, 0, 100, 18, 0, 0, 0, 0, {"zoom", "none"})
	local mask = scene:get(self.path .. "/Mask")
	local contents = scene:get(self.path .. "/Mask/contents")
	scene:add(button, contents)
	contents:add(button)
	mask:setMaskOnChildren()
end

function M.setActiveScene(self, sceneName)
end

return M
