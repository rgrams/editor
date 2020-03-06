
local tex = require "theme.textures"
local fnt = require "theme.fonts"

local function ruuinput(self, action, value, change, isRepeat)
	if action == "close tab" and change == 1 then
		local tabBar = scene:get("/root/mainColumn/mainRow/editScenePanel/VPColumn/TabBar")
		tabBar:call("closeScene", self._sceneName)
	end
end

local function new(sceneName, x, y, angle, w, h, px, py, ax, ay, resizeMode)
	w, h = w or 70, h or 24
	local self = gui.Slice(
		tex.Button_Normal, nil, {5, 6}, x, y, angle, w, h, px, py, ax, ay, resizeMode
	)
	local label = gui.Text(sceneName, fnt.default, 0, -1, 0, w, -1, 0, -1, 0, "center", "fill")
	label.layer = "text"
	label.name = "label"
	self.label = label
	self.children = { label }
	self.color[1], self.color[2], self.color[3] = 0.75, 0.75, 0.75
	self.name = sceneName
	self.layer = "widgets"
	self.ruuinput = ruuinput
	return self
end

return new
