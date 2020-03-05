
local M = {}

local active = require "activeData"
local sceneManager = require "sceneManager"
local Button = require "theme.widgets.Button"

local function setActiveScene(self)
	local tabBar = scene:get("/root/mainColumn/mainRow/editScenePanel/VPColumn/TabBar")
	tabBar:call("setActiveScene", self._sceneName)
end

function M.newScene(self, sceneName)
	print("TabBar.newScene "..tostring(sceneName))
	local button = Button(sceneName, 0, 0, 0, 100, 18, 0, 0, 0, 0, {"zoom", "none"})
	button._sceneName = sceneName
	local mask = scene:get(self.path .. "/Mask")
	local contents = scene:get(self.path .. "/Mask/contents")
	scene:add(button, contents)
	contents:add(button)
	mask:setMaskOnChildren()
	active.ruu:makeButton(button, true, setActiveScene)
end

function M.setActiveScene(self, sceneName)
	sceneManager.setActiveScene(sceneName)
end

return M
