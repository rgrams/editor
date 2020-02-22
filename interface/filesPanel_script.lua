
local script = {}

local FileWidget = require "theme.widgets.files.File"
local FolderWidget = require "theme.widgets.files.Folder"
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
				self.ruu:destroyWidget(child)
			end
		end
		self.contents.h = 10
	end
end

local function setContentsVisible(self, visible)
	for i,obj in ipairs(self.containedObjects) do
		obj:setVisible(visible)
		self.ruu:setWidgetEnabled(obj, visible)
		obj.originalH = visible and 24 or 0
		if obj.containedObjects then
			if (not visible) or (visible and obj.isOpen) then
				setContentsVisible(obj, visible)
			end
		end
	end
	self.parent:refresh()
end

local function toggleFolder(self)
	self.isOpen = not self.isOpen
	self.arrow.angle = self.isOpen and 0 or -math.pi/2

	-- The first time the folder gets opened, load its contents.
	if self.isOpen and not self.isLoaded then
		self.isLoaded = true
		local colIdx = self.parent:getChildIndex(self)
		local files = love.filesystem.getDirectoryItems(self.filepath)
		self.filesPanel:call("addFiles", files, self.filepath .. "/", self.indentLevel + 1, colIdx)

		-- Convert file name list to a list of the corresponding widget objects, and store it.
		local basePath = self.parent.path .. "/" .. self.filepath .. "/"
		for i,fileName in ipairs(files) do
			local scenePath = basePath .. fileName
			local obj = scene:get(scenePath)
			files[i] = obj
		end
		self.containedObjects = files
	elseif self.isOpen then -- Folder opened, show its contents.
		setContentsVisible(self, true)
		self.filesPanel:call("reMapWidgets")
	else
		setContentsVisible(self, false)
		self.filesPanel:call("reMapWidgets")
	end
end

local function fileBtnReleased(self)
	if self.doubleClickT then
		self.doubleClickT = SETTINGS.doubleClickTime
		if self.isFolder then
			toggleFolder(self)
		end
	else
		self.doubleClickT = SETTINGS.doubleClickTime
		self.update = self.doubleClickUpdate
	end
end

function script.reMapWidgets(self)
	local map = {}
	if self.contents.startChildren then
		for i,childData in ipairs(self.contents.startChildren) do
			local obj = childData.obj
			if obj.name ~= "deletedMarker" and obj.visible then
				table.insert(map, {obj})
			end
		end
	end
	if #map > 0 then
		self.ruu:mapNeighbors(map)
	end
end

local function sortFoldersFirst(files, basePath)
	local folders
	for i=#files,1,-1 do
		local fileName = files[i]
		local info = love.filesystem.getInfo(basePath .. fileName)
		if not info then
			table.remove(files, i)
		else
			if info.type == "directory" then
				table.remove(files, i)
				folders = folders or {}
				table.insert(folders, fileName)
			end
		end
	end
	if folders then
		for i=1,#folders do
			table.insert(files, 1, folders[i])
		end
	end
end

function script.addFiles(self, files, basePath, indentLevel, columnIndex)
	shouldRedraw = true
	basePath = basePath or "project/"
	indentLevel = indentLevel or 0
	sortFoldersFirst(files, basePath)
	local filesPanel = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files")
	local contentsColumn = scene:get("/root/mainColumn/mainRow/leftPanel/panel/Column/Files/contents")
	for i,fileName in ipairs(files) do
		local path = basePath .. fileName
		local info = love.filesystem.getInfo(path)
		assert(info, "Failed to load file at path: " .. path)

		if columnIndex then  columnIndex = columnIndex + 1  end -- Don't bother unless we're starting in the middle.
		local wgt
		if info.type == "directory" then
			wgt = FolderWidget(fileName, path, indentLevel)
		else
			wgt = FileWidget(fileName, path, indentLevel)
		end
		wgt.filesPanel = filesPanel
		contentsColumn.h = contentsColumn.h + wgt.h
		contentsColumn:_updateInnerSize()
		scene:add(wgt, contentsColumn)
		contentsColumn:add(wgt, nil, nil, columnIndex)
		filesPanel:setMaskOnChildren()

		self.ruu:makeButton(wgt, true, fileBtnReleased, "FileWidget")
	end
	self:call("reMapWidgets")
end

function script.setFolder(self, folderPath)
	self.basePath = folderPath .. "/"
	self:call("clearContents")
	local files = love.filesystem.getDirectoryItems(folderPath)
	self:call("addFiles", files, self.basePath)
end

return script
