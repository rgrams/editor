
local M = {}

local active = require "activeData"
local encoder = require "lib.encoder"
local FileDialog = require "theme.widgets.FileDialog"

local function saveToAbsolutePath(data, absPath)
	local messager = scene:get("/root/overlay")
	local file, errorMsg = io.open(absPath, "w")
	if file then
		file:write(data)
		file:close()
		print("    Success!")
	else
		print(errorMsg)
		messager:call("message", "Error: "..errorMsg)
	end
	return file, errorMsg
end

local function saveSceneFile(self, mountedBasePath, absBasePath, filename, obj)
	if absBasePath then
		local messager = scene:get("/root/overlay")

		local absFilePath = absBasePath .. filename
		local mountedFilePath = mountedBasePath .. filename
		print("Saving to Path: "..absFilePath)
		-- Filepath has already been checked, if it's an overwrite then it's already been confirmed.
		local data = encoder.encode(obj)
		-- Use `mountedPath` to check the file.
		-- Use `absFilepath` to write the file.
		local info = love.filesystem.getInfo(mountedFilePath)
		if info then
			print("  Saving over existing file "..mountedFilePath)
			messager:call("message", "Saving file "..mountedFilePath)
		else
			print("  Writing new file "..absFilePath)
			messager:call("message", "Saving new file "..mountedFilePath)
		end
		saveToAbsolutePath(data, absFilePath)
		self.lastSaveFolder = mountedBasePath
	end
end

function M.input(self, action, value, change, isRepeat, x, y, dx, dy)
	if action == "save" and change == 1 then
		local obj = active.scene.children[1]
		local dialog = FileDialog(self.lastSaveFolder or "project/", "Save", saveSceneFile, self, obj)
		scene:add(dialog, self)
	end
end

return M
