
local script = {}

local fnt = require "theme.fonts"

function script.init(self)
	self.contents = scene:get(self.path .. "/contents")
end

function script.clearContents(self)
	if self.contents.children then
		for i,child in ipairs(self.contents.children) do
			if child.name ~= "deletedMarker" then
				scene:remove(child)
				self.contents:remove(child)
			end
		end
		self.contents.h = 10
	end
end

local function addFiles(basePath, files, indentLevel)
	indentLevel = indentLevel or 0
	local indent = string.rep("\t", indentLevel)
	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files")
	local contentsColumn = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files/contents")
	for k,fileName in ipairs(files) do
		local path = basePath .. fileName
		local info = love.filesystem.getInfo(path)
		assert(info, "Failed to load file at path: " .. path)

		local btn = gui.Text(indent .. fileName, fnt.files, 0, 0, 0, 500, -1, 0, -1, 0, "left", "none")
		btn.layer = "text"
		contentsColumn.h = contentsColumn.h + btn.h
		contentsColumn:_updateInnerSize()
		scene:add(btn, contentsColumn)
		contentsColumn:add(btn)
		filesPanel:setMaskOnChildren()

		if info.type == "directory" then
			addFiles(path .. "/", love.filesystem.getDirectoryItems(path), indentLevel + 1)
		end
	end
end

local projectPath

function love.directorydropped(path)
	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files")
	filesPanel:call("clearContents")
	if projectPath then  love.filesystem.unmount(projectPath)  end
	projectPath = path
	love.filesystem.mount(projectPath, "project")
	local files = love.filesystem.getDirectoryItems("project")
	addFiles("project/", files)
end

return script
