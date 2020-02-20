
local script = {}

local fnt = require "theme.fonts"
local FileWidget = require "theme.widgets.files.File"
local activeData = require "activeData"

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

local function fileBtnReleased(self)
	if self.doubleClickT then
		print(self.filepath)
		self.doubleClickT = SETTINGS.doubleClickTime
	else
		self.doubleClickT = SETTINGS.doubleClickTime
		self.update = self.doubleClickUpdate
	end
end

local function addFiles(basePath, files, indentLevel, widgetMap)
	indentLevel = indentLevel or 0
	local indent = string.rep("\t", indentLevel)
	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files")
	local contentsColumn = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files/contents")
	local ruu = activeData.ruu
	widgetMap = widgetMap or {}
	for k,fileName in ipairs(files) do
		local path = basePath .. fileName
		local info = love.filesystem.getInfo(path)
		assert(info, "Failed to load file at path: " .. path)

		local btn = FileWidget(indent .. fileName, path)
		contentsColumn.h = contentsColumn.h + btn.h
		contentsColumn:_updateInnerSize()
		scene:add(btn, contentsColumn)
		contentsColumn:add(btn)
		filesPanel:setMaskOnChildren()

		ruu:makeButton(btn, true, fileBtnReleased, "FileWidget")
		table.insert(widgetMap, {btn})

		if info.type == "directory" then
			addFiles(path .. "/", love.filesystem.getDirectoryItems(path), indentLevel + 1, widgetMap)
		end
	end
	return widgetMap
end

function script.folderDropped(self, path)
	if self.projectPath then
		love.filesystem.unmount(self.projectPath)
		self:call("clearContents")
	end
	self.projectPath = path
	love.filesystem.mount(self.projectPath, "project")
	local files = love.filesystem.getDirectoryItems("project")
	local widgetMap = addFiles("project/", files, 1)
	local ruu = activeData.ruu
	ruu:mapNeighbors(widgetMap)
end

function love.directorydropped(path)
	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files")
	filesPanel:call("folderDropped", path)
end

return script
