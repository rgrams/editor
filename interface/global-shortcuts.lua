
local M = {}

local active = require "activeData"
local encoder = require "lib.encoder"
local FileDialog = require "theme.widgets.FileDialog"
local sceneManager = require "sceneManager"

local function saveToAbsolutePath(data, absFilePath)
	local messager = scene:get("/root/overlay")
	local file, errorMsg = io.open(absFilePath, "w")
	if file then
		file:write(data)
		file:close()
		print("    Success!")
	else
		print(errorMsg)
		messager:call("message", "ERROR: "..errorMsg, "error")
		messager:call("message", "failed to save", "error")
	end
	return file, errorMsg
end

local function saveScene(self, mountFolderPath, absFolderPath, filename, obj)
	if absFolderPath then
		local messager = scene:get("/root/overlay")

		local absFilePath = absFolderPath .. filename
		local mountFilePath = mountFolderPath .. filename
		print("Saving to Path: "..absFilePath)
		-- Filepath has already been checked, if it's an overwrite then it's already been confirmed.
		local data = encoder.encode(obj)
		-- Use mounted path to check the file.
		-- Use absolute path to write the file.
		local info = love.filesystem.getInfo(mountFilePath)
		if info then
			print("  Saving over existing file "..mountFilePath)
			messager:call("message", "Saving file "..mountFilePath)
		else
			print("  Writing new file "..absFilePath)
			messager:call("message", "Saving new file "..mountFilePath)
		end
		saveToAbsolutePath(data, absFilePath)
		self.lastSaveFolder = mountFolderPath
	end
end

local function save(self)
	local obj = active.scene.children[1]
	local data = encoder.encode(obj)
	local messager = scene:get("/root/overlay")
	messager:call("message", "Saving file "..active.sceneName)
	saveToAbsolutePath(data, active.absFilePath)
end

local function saveAs(self)
	local obj = active.scene.children[1]
	local dialog = FileDialog(self.lastSaveFolder or "project/", "Save As...", saveScene, self, obj)
	scene:add(dialog, self)
end

function M.input(self, action, value, change, isRepeat, x, y, dx, dy)
	if action == "save as" and change == 1 then
		saveAs(self)
		return true
	elseif action == "save" and change == 1 then
		local obj = active.scene.children[1]
		if active.absFilePath then  save(self)
		else  saveAs(self)  end
		return true
	elseif action == "close tab" and change == 1 then
		local tabBar = scene:get("/root/mainColumn/mainRow/editScenePanel/VPColumn/TabBar")
		tabBar:call("sceneClosed", active.sceneName)
		sceneManager.removeScene(active.sceneName)
	end
end

return M
