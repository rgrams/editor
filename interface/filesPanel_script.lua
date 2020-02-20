
local script = {}

local fnt = require "theme.fonts"
local FileWidget = require "theme.widgets.files.File"
local FolderWidget = require "theme.widgets.files.Folder"
local activeData = require "activeData"

function script.init(self)
	self.contents = scene:get(self.path .. "/contents")
end

function script.clearContents(self)
	if self.contents.children then
		local ruu = activeData.ruu
		for i,child in ipairs(self.contents.children) do
			if child.name ~= "deletedMarker" then
				scene:remove(child)
				self.contents:remove(child)
				ruu:destroyWidget(child)
			end
		end
		self.contents.h = 10
	end
end

local function fileBtnReleased(self)
	if self.doubleClickT then
		print(self.filepath)
		self.doubleClickT = SETTINGS.doubleClickTime
		if self.isFolder then
			self.isOpen = not self.isOpen
			self.arrow.angle = self.isOpen and 0 or -math.pi/2
		end
	else
		self.doubleClickT = SETTINGS.doubleClickTime
		self.update = self.doubleClickUpdate
	end
end

local function addFiles(basePath, files, indentLevel, widgetMap)
	indentLevel = indentLevel or 0
	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files")
	local contentsColumn = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files/contents")
	local ruu = activeData.ruu
	widgetMap = widgetMap or {}
	for k,fileName in ipairs(files) do
		local path = basePath .. fileName
		local info = love.filesystem.getInfo(path)
		assert(info, "Failed to load file at path: " .. path)

		local wgt
		if info.type == "directory" then
			wgt = FolderWidget(fileName, path, indentLevel)
		else
			wgt = FileWidget(fileName, path, indentLevel)
		end
		contentsColumn.h = contentsColumn.h + wgt.h
		contentsColumn:_updateInnerSize()
		scene:add(wgt, contentsColumn)
		contentsColumn:add(wgt)
		filesPanel:setMaskOnChildren()

		ruu:makeButton(wgt, true, fileBtnReleased, "FileWidget")
		table.insert(widgetMap, {wgt})

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
	local widgetMap = addFiles("project/", files)
	local ruu = activeData.ruu
	ruu:mapNeighbors(widgetMap)
end

function love.directorydropped(path)
	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files")
	filesPanel:call("folderDropped", path)
end

return script
