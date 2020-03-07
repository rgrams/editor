
local script = {}

local FileWidget = require "theme.widgets.files.File"
local FolderWidget = require "theme.widgets.files.Folder"
local activeData = require "activeData"

function script.init(self)
	self.contents = scene:get(self.path .. "/Column/Mask/contents")
	self.scrollArea = scene:get(self.path .. "/Column/Mask")
end

function script.clear(self)
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

local function setContentsVisible(self, visible, ruu)
	for i,obj in ipairs(self.containedObjects) do
		obj:setVisible(visible)
		ruu:setWidgetEnabled(obj, visible)
		obj.designH = visible and 24 or 0
		if obj.containedObjects then
			if (not visible) or (visible and obj.isOpen) then
				setContentsVisible(obj, visible, ruu)
			end
		end
	end
	self.parent:refresh()
end

local function toggleFolder(folder)
	folder.isOpen = not folder.isOpen
	folder.arrow.angle = folder.isOpen and 0 or -math.pi/2

	-- The first time the folder gets opened, load its contents.
	if folder.isOpen and not folder.isLoaded then
		folder.isLoaded = true
		local columnIndex = folder.parent:getChildIndex(folder)
		local files = love.filesystem.getDirectoryItems(folder.mountFilePath)
		local mountPath, indent = folder.mountFilePath, folder.indentLevel + 1
		folder.filesPanel:call("addFiles", files, mountPath, indent, columnIndex)

		-- Convert file name list to a list of the corresponding widget objects, and store it.
		for i,filename in ipairs(files) do
			local info = love.filesystem.getInfo(folder.mountFilePath .. filename)
			if info.type == "directory" then  filename = filename .. "/"  end
			local objPath = folder.path .. filename -- NOT a filepath, the path to the object.
			local obj = scene:get(objPath)
			files[i] = obj
		end
		folder.containedObjects = files
	elseif folder.isOpen then -- Folder opened, show its contents.
		setContentsVisible(folder, true, folder.ruu)
		folder.filesPanel:call("reMapWidgets")
	else
		setContentsVisible(folder, false, folder.ruu)
		folder.filesPanel:call("reMapWidgets")
	end
end

local function activateFile(file)
	if file.isFolder then
		if file.filesPanel.showSingleFolder then
			file.filesPanel:call("setFolder", file.mountFilePath)
		else
			toggleFolder(file)
		end
	else
		file.filesPanel:call("fileDoubleClicked", file)
	end
end

local function fileBtnReleased(file, mx, my, isKeyboard)
	if isKeyboard then
		activateFile(file)
	else
		if file.doubleClickT then
			file.doubleClickT = SETTINGS.doubleClickTime
			activateFile(file)
		else
			if not file.isFolder then  file.filesPanel:call("fileClicked", file)  end
			file.doubleClickT = SETTINGS.doubleClickTime
			file.update = file.doubleClickUpdate
		end
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

local function sortFoldersFirst(files, mountFolderPath)
	local folders
	for i=#files,1,-1 do
		local filename = files[i]
		local info = love.filesystem.getInfo(mountFolderPath .. filename)
		if not info then
			table.remove(files, i)
		else
			if info.type == "directory" then
				table.remove(files, i)
				folders = folders or {}
				table.insert(folders, filename)
			end
		end
	end
	if folders then
		for i=1,#folders do
			table.insert(files, 1, folders[i])
		end
	end
end

function script.addFiles(self, files, mountFolderPath, indentLevel, columnIndex)
	shouldRedraw = true
	mountFolderPath = mountFolderPath or PROJECT_PATH
	indentLevel = indentLevel or 0
	sortFoldersFirst(files, mountFolderPath)
	local contentsColumn = self.contents

	-- Expand contents Column to fit new files & update its transform stuff.
	contentsColumn.h = contentsColumn.h + #files * 24
	contentsColumn:_updateInnerSize() -- Update innerH based on new H - padY.
	contentsColumn:updateTransform()

	for i,filename in ipairs(files) do
		local mountFilePath = mountFolderPath .. filename
		local info = love.filesystem.getInfo(mountFilePath)
		assert(info, "Failed to load file at path: " .. mountFilePath)

		if columnIndex then  columnIndex = columnIndex + 1  end -- Don't bother unless we're starting in the middle.
		local wgt
		if info.type == "directory" then
			wgt = FolderWidget(filename, mountFilePath .. "/", indentLevel, self.isPopup)
			wgt.ruu = self.ruu -- Needs for show/hide contents.
		else
			wgt = FileWidget(filename, mountFilePath, indentLevel, self.isPopup)
		end
		wgt.filesPanel, wgt.absFolderPath = self, self.absFolderPath
		scene:add(wgt, contentsColumn) -- Get added to the SceneTree at the center of the contentsColumn.
		contentsColumn:add(wgt, nil, nil, columnIndex) -- Get their parentOffset set, W/H possibly changed.
		wgt:updateTransform() -- May also do this during `parentResized` if their W or H has changed...
		self.scrollArea:setMaskOnChildren()

		self.ruu:makeButton(wgt, true, fileBtnReleased, "FileWidget")
	end
	self:call("reMapWidgets")
	self.ruu:mouseMoved(self.ruu.mx, self.ruu.my, 0, 0) -- Added new widgets, re-check for hover.
end

function script.goUp(self)
	if not self.showSingleFolder or not self.mountFolderPath then  return  end
	local path = self.mountFolderPath
	local pattern = "(.+/).+$"
	local parentPath = string.match(path, pattern)
	if parentPath then  self:call("setFolder", parentPath)  end
end

function script.ruuinput(self, name, value, change)
	-- backspace for goUp, alt-up for goUp
	if change == 1 then
		if name == "backspace" or name == "back" then
			self:call("goUp")
		elseif name == "up" then
			if Input.get("alt") == 1 then
				self:call("goUp")
			end
		end
	end
end

function script.setFolder(self, newMountFolderPath)
	self.mountFolderPath = newMountFolderPath
	local relFolder = string.sub(newMountFolderPath, PROJECT_PATH:len())
	-- love.filesystem.getRealDirectory only gets the path to the root folder that was mounted.
	local rootAbsFolderPath = love.filesystem.getRealDirectory(self.mountFolderPath)
	-- Use editor directory if nothing is mounted.
	rootAbsFolderPath = rootAbsFolderPath or love.filesystem.getWorkingDirectory()
	self.absFolderPath = rootAbsFolderPath .. relFolder
	self:call("clear")
	local files = love.filesystem.getDirectoryItems(self.mountFolderPath)
	self:call("addFiles", files, self.mountFolderPath)
	local firstFileWidget = self.contents.startChildren[1]
	firstFileWidget = firstFileWidget and firstFileWidget.obj
	if firstFileWidget then  self.ruu:setFocus(firstFileWidget)  end -- Folder could be empty.
end

return script
