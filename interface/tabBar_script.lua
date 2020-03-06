
local M = {}

local active = require "activeData"
local sceneManager = require "sceneManager"
local Tab = require "theme.widgets.Tab"

-- Tab Button release function.
local function setActiveScene(tabBtn)
	local tabBar = scene:get("/root/mainColumn/mainRow/editScenePanel/VPColumn/TabBar")
	tabBar:call("setActiveScene", tabBtn._sceneName)
end

function M.closeScene(self, sceneName)
	local contents = scene:get(self.path .. "/Mask/contents")
	local tabBtn = scene:get(self.path .. "/Mask/contents/" .. sceneName)
	contents:remove(tabBtn)
	scene:remove(tabBtn)
	active.ruu:destroyWidget(tabBtn)
	sceneManager.removeScene(sceneName)
end

function M.newScene(self, sceneName)
	local tabBtn = Tab(sceneName, 0, 0, 0, 100, 18, 0, 0, 0, 0, {"zoom", "none"})
	tabBtn._sceneName = sceneName
	local mask = scene:get(self.path .. "/Mask")
	local contents = scene:get(self.path .. "/Mask/contents")
	scene:add(tabBtn, contents)
	contents:add(tabBtn)
	mask:setMaskOnChildren()
	active.ruu:makeButton(tabBtn, true, setActiveScene)
end

function M.setActiveScene(self, sceneName)
	sceneManager.setActiveScene(sceneName)
end

return M
