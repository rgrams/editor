
local tex = require "theme.textures"
local fnt = require "theme.fonts"

-- Each time you click it should restart the timer.
-- If the timer value still exists on click, it's a double-click.
local function doubleClickUpdate(self, dt)
	self.doubleClickT = self.doubleClickT - dt
	if self.doubleClickT <= 0 then
		self.doubleClickT = nil
		self.update = nil
	end
end

local function new(filename, mountFilePath, indent, isPopup)
	local indentPos = indent * SETTINGS.filesIndentSize
	local self = mod(gui.Slice(tex.Panel, nil, {2}, 0, 0, 0, 100, 24, -1, 0, -1, 0, {"fill", "none"}), {
		filename = filename,
		mountFilePath = mountFilePath, -- Full path including `filename`. Includes the ending "/"
		doubleClickUpdate = doubleClickUpdate,
		indentLevel = indent,
		isFolder = true,
		isOpen = false,
		color = {0.75, 0.75, 0.75, 0.5},
		name = mountFilePath,
		layer = isPopup and "popupWidgets" or "widgets",
		children = {
			mod(gui.Text(filename, fnt.files, 14 + indentPos, -1, 0, 4000, -1, 0, -1, 0, "left", "none"), {
				name = "label",
				layer = isPopup and "popupText" or "text"
			}),
			gui.Sprite(tex.FolderArrow, 7+indentPos, 0, -math.pi/2, 1, 1, nil, 0, 0, -1, 0)
		}
	})
	self.label = self.children[1]
	self.arrow = self.children[2]
	return self
end

return new
