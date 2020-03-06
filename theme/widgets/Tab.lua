
local tex = require "theme.textures"
local fnt = require "theme.fonts"

local function ruuinput(self, action, value, change, isRepeat)
	if action == "close tab button" and change == 1 then
		local tabBar = scene:get("/root/mainColumn/mainRow/editScenePanel/VPColumn/TabBar")
		tabBar:call("closeScene", self._sceneName)
	end
end

local function new(sceneName, x, y, angle, w, h, px, py, ax, ay, resizeMode)
	w, h = w or 70, h or 18
	local self = gui.Slice(
		tex.Tab_Normal, nil, {6, 0}, x, y, angle, w, h, px, py, ax, ay, resizeMode
	)
	local label = gui.Text(sceneName, fnt.default, 0, -1, 0, w, -1, 0, -1, 0, "center", "fill")
	label.layer = "text"
	label.name = "label"
	self.label = label
	self.children = { label }
	self.name = sceneName
	self.layer = "widgets"
	self.ruuinput = ruuinput
	return self
end

return new
