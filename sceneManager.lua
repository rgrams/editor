
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
	shouldRedraw = true
	local sceneData = M.scenes[name]
	if not sceneData then
		print("sceneManager.setActiveScene: No scene by the name '"..tostring(name).."' exists.")
		return
	end
	local cam = scene:get("/ViewportCamera")
	if cam then
		if active.scene then
			local oldSceneData = M.scenes[active.sceneName]
			oldSceneData.camX, oldSceneData.camY = cam.pos.x, cam.pos.y
			oldSceneData.camZoom = cam.zoom
		end
		local x, y = sceneData.camX or 0, sceneData.camY or 0
		local zoom = sceneData.camZoom or 1
		cam.pos.x, cam.pos.y, cam.zoom = x, y, zoom
	end

	active.sceneName = sceneData.name
	active.scene = sceneData.scene  active.selection = sceneData.selection
	active.commands = sceneData.commands  active.absFilePath = sceneData.absFilePath
end

function M.sceneExists(name)
	return M.scenes[name]
end

function M.newScene(name, absFilePath, inBackground)
	name = name or "untitled_0"
	while M.scenes[name] do
		local baseName = string.sub(name, 0, -2)
		if baseName ~= "untitled_" then
			-- Tried to open a file that is already open.
			local messager = scene:get("/root/overlay")
			messager:call("message", "That file is already open.", "warning")
			return true
		end
		local idx = tonumber(string.sub(name, -1))
		name = baseName .. idx + 1
	end

	local scn = SceneTree(drawLayers, defaultLayer) -- Don't shadow global `scene`.
	local selection = Selection()
	local commands = Commands(allCommands)

	local sceneData = {
		name = name,
		scene = scn, selection = selection,
		commands = commands, absFilePath = absFilePath
	}
	M.scenes[name] = sceneData
	local tabBar = scene:get("/root/mainColumn/mainRow/editScenePanel/VPColumn/TabBar")
	tabBar:call("newScene", name)
	if not inBackground then  M.setActiveScene(name)  end
end

function M.removeScene(name)
	if not M.scenes[name] then
		print("sceneManager.removeScene: No scene by the name '"..tostring(name).."' exists.")
		return
	end
	M.scenes[name] = nil
	if active.sceneName == name then
		active.scene, active.selection, active.commands = nil, nil, nil
		local sceneName, sceneData = next(M.scenes)
		if sceneData then  M.setActiveScene(sceneName)
		else  M.newScene()  end
	end
end

return M