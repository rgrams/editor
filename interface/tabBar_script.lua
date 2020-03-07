
local M = {}

local active = require "activeData"
local sceneManager = require "sceneManager"
local Tab = require "theme.widgets.Tab"

local function tabBtnReleased(tabBtn)
	sceneManager.setActiveScene(tabBtn._sceneName)
end

local function mapTabNeighbors(self)
	local contents = scene:get(self.path .. "/Mask/contents")
	local xMap = {}
	for i,rowChildData in ipairs(contents.startChildren) do
		table.insert(xMap, rowChildData.obj)
	end
	active.ruu:mapNeighbors({ xMap })
end

local function removeTab(self, sceneName)
	local contents = scene:get(self.path .. "/Mask/contents")
	local tabBtn = scene:get(self.path .. "/Mask/contents/" .. sceneName)
	contents:remove(tabBtn)
	scene:remove(tabBtn)
	active.ruu:destroyWidget(tabBtn)
	mapTabNeighbors(self)
end

local function loopIndex(listLength, start, by)
	return (start - 1 + by) % listLength + 1
end

function M.switchToScene(self, sceneName)
	local tabBtn = scene:get(self.path .. "/Mask/contents/" .. sceneName)
	if tabBtn then
		tabBtn:setChecked(true)
		sceneManager.setActiveScene(sceneName)
	end
end

function M.switchScenes(self, toPrev)
	local contents = scene:get(self.path .. "/Mask/contents")
	local tabBtn = scene:get(self.path .. "/Mask/contents/" .. active.sceneName)
	local i = contents:getChildIndex(tabBtn)
	i = loopIndex(#contents.startChildren, i, toPrev and -1 or 1)
	local nextTabBtn = contents.startChildren[i].obj
	sceneManager.setActiveScene(nextTabBtn._sceneName)
	nextTabBtn:setChecked(true)
end

-- Called from other scripts.
function M.closeScene(self, sceneName)
	removeTab(self, sceneName)
	sceneManager.removeScene(sceneName)
end

-- Called from Tab widget.
function M.sceneClosed(self, sceneName)
	removeTab(self, sceneName)
end

function M.newScene(self, sceneName)
	local tabBtn = Tab(sceneName)
	tabBtn._sceneName = sceneName
	local mask = scene:get(self.path .. "/Mask")
	local contents = scene:get(self.path .. "/Mask/contents")
	scene:add(tabBtn, contents)
	if #contents.startChildren == 0 then
		active.ruu:makeRadioButtonGroup({tabBtn}, true, tabBtn, tabBtnReleased, "Tab")
	else
		local sib = contents.startChildren[1].obj
		active.ruu:makeRadioButton(tabBtn, sib, true, true, tabBtnReleased, "Tab")
	end
	contents:add(tabBtn)
	mapTabNeighbors(self)
	mask:setMaskOnChildren()
end

return M
