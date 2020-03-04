
local script = {}

local activeData = require "activeData"

local objProp = require "object.object-properties"

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
	print("FilesPanel - Attepmting to load file: "..fileWgt.filepath)
	local extension = string.match(fileWgt.filename, "%.(%w-)$")
	print("  file extension = "..tostring(extension))

	if extension == "lua" then
		print("  loading file...")
		local localPath = string.sub(fileWgt.filepath, ("project/"):len())
		local absPath = fileWgt.realBasePath..localPath
		local success, val = pcall(dofile, absPath)
		if success then  print("    Success!")
		else  print("    Failed! "..val)  end
		if success and type(val) == "function" then
			local obj = val()
			if type(obj) == "table" and obj.is and obj:is(Object) then
				print("      Successfully loaded a scene file, adding to edit scene...")
				recursiveSetTree(obj, editScene)
				local addData = getChildrenReCreationData({obj})
				local cmd = activeData.commands
				cmd:perform("addObject", unpack(addData[1]))
			end
		end
	end
end

return script
