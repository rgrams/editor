
local script = {}

local active = require "activeData"
local sceneManager = require "sceneManager"
local objProp = require "object.object-properties"
local sceneCommands = require "commands.scene-commands"
local setget = require "object.object-prop-set-getters"
local projectPath, displayPath = setget.projectPath, setget.displayPath

local original_new = { image = new.image, font = new.font, audio = new.audio }

-- Temporarily patch onto the `new` functions to convert paths to "project/" paths.
local function changeNewForLoading()
	for k,fn in pairs(original_new) do
		new[k] = function(filePath, ...)
			return fn(projectPath(filePath), ...)
		end
	end
end
-- Reset the `new` functions to their originals.
local function resetNewAfterLoading()
	for k,fn in pairs(original_new) do  new[k] = fn  end
end

local function getModifiedProperties(obj)
	local modProps
	local classPropDict = objProp[obj.className] or objProp.Object
	for propName,data in pairs(classPropDict) do
		local curVal = objProp.getValue(obj, propName)
		local defaultVal = objProp.getDefault(obj.className, propName)
		if not objProp.areValuesEqual(curVal, defaultVal) then
			modProps = modProps or {}
			modProps[propName] = curVal
		end
	end
	return modProps
end

-- Recursively make a sequence of sequences of `addObject` args.
local function getChildrenReCreationData(objects, parent)
	if not objects then  return false  end
	local t = false
	for i,obj in ipairs(objects) do
		if obj.name ~= "deletedMarker" then
			t = t or {}
			local modProps = getModifiedProperties(obj)
			local enclosure = {}
			obj[PRIVATE_KEY] = enclosure
			obj.parent = parent
			local parentEnclosure = obj.parent and obj.parent[PRIVATE_KEY] -- or nil
			local children = getChildrenReCreationData(obj.children, obj)

			local args = {obj.className, enclosure, obj.tree, parentEnclosure, modProps, children}
			table.insert(t, args)
		end
	end
	return t
end

local function recursiveSetTree(obj, tree)
	obj.tree = tree
	if obj.children then
		for i,child in ipairs(obj.children) do
			recursiveSetTree(child, tree)
		end
	end
end

function script.fileDoubleClicked(self, fileWgt)
	local messager = scene:get("/root/overlay")

	print("FilesPanel - Attempting to load file: "..fileWgt.mountFilePath)
	local extension = string.match(fileWgt.filename, "%.(%w-)$")
	print("  file extension = "..tostring(extension))
	if extension == "lua" then
		print("  loading file...")
		local localMountPath = string.sub(fileWgt.mountFilePath, PROJECT_PATH:len())
		local absFilePath = fileWgt.absFolderPath..localMountPath
		local success, val = pcall(dofile, absFilePath)
		if not success then
			messager:call("message", "Loading failed - Module crashed on load.", "warning")
			return
		elseif success and type(val) == "function" then

			changeNewForLoading() -- To convert file paths to their mounted versions.
			local obj = val()
			resetNewAfterLoading()

			if type(obj) == "table" and obj.is and obj:is(Object) then
				print("    Successfully loaded a scene file, adding to edit scene...")
				local isAlreadyOpen = sceneManager.newScene(localMountPath, absFilePath)
				if isAlreadyOpen then
					if active.sceneName == localMountPath then
						messager:call("message", "That's the file you have open right now.")
					else
						messager:call("message", "File is already open, switching to it now.")
						local tabBar = scene:get("/root/mainColumn/mainRow/editScenePanel/VPColumn/TabBar")
						tabBar:call("switchToScene", localMountPath)
					end
					return
				end
				recursiveSetTree(obj, active.scene)
				local addData = getChildrenReCreationData({obj})
				local addObject = sceneCommands.addObject[1]
				addObject(unpack(addData[1]))
				messager:call("message", "Loaded scene file: "..localMountPath)
				return
			end
		end
	end
	messager:call("message", "Loading failed, that's not a valid scene file.", "warning")
end

return script
