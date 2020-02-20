
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

local function new(text, path)
	local self = mod(gui.Slice(tex.Panel, nil, {2}, 0, 0, 0, 100, 24, -1, 0, -1, 0, {"fill", "none"}), {
		filepath = path,
		doubleClickUpdate = doubleClickUpdate,
		isFolder = true,
		isOpen = false,
		color = {0.75, 0.75, 0.75, 1},
		name = text,
		layer = "widgets",
		children = {
			mod(gui.Text(text, fnt.files, 14, -1, 0, 600, -1, 0, -1, 0, "left", "none"), {
				name = "label",
				layer = "text"
			}),
			mod(gui.Sprite(tex.FolderArrow, 0, 0, -math.pi/2, 1, 1, nil, 0, 0, -1, 0), {parentOffsetX = 7})
		}
	})
	self.label = self.children[1]
	self.arrow = self.children[2]
	return self
end

return new
