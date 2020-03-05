
local M = {}

local active = require "activeData"
local Selection = require "Selection"
local Commands = require "philtre.commands"
local allCommands = require "commands.all-commands"

local drawLayers = {
	editScene = { "entities" },
	viewportDebug = { "viewportDebug" }
}
defaultLayer = "entities"

M.scenes = {}

function M.setActiveScene(name)
	local sceneData = M.scenes[name]
	if not sceneData then
		print("sceneManager.setActiveScene: No scene by then name '"..tostring(name).."' exists.")
		return
	end
	active.sceneName = sceneData.name
	active.scene = sceneData.scene  active.selection = sceneData.selection
	active.commands = sceneData.commands  active.filepath = sceneData.filepath
end

function M.newScene(filepath)
	local scene = SceneTree(drawLayers, defaultLayer)
	local selection = Selection()
	local commands = Commands(allCommands)

	local name = filepath or "untitled_0"
	while M.scenes[name] do
		local idx = tonumber(string.sub(name, -1))
		name = string.sub(name, 0, -2) .. idx + 1
	end

	local sceneData = {
		name = name,
		scene = scene, selection = selection,
		commands = commands, filepath = filepath
	}
	active.sceneName = name
	active.scene = scene  active.selection = selection
	active.commands = commands  active.filepath = filepath

	M.scenes[name] = sceneData
end

function M.removeScene(name)
	if not M.scenes[name] then
		print("sceneManager.removeScene: No scene by then name '"..tostring(name).."' exists.")
		return
	end
	M.scenes[name] = nil
	if active.sceneName == name then
		local sceneData = next(M.scenes)
		if sceneData then  M.setActiveScene(sceneData.name)
		else  M.newScene()  end
	end
end

return M