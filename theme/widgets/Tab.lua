
local tex = require "theme.textures"
local fnt = require "theme.fonts"

local script = {}

function script.focus(self, isKeyboard)
	if isKeyboard then
		self:releaseFunc()
		self:setChecked(true)
	end
end

local function ruuinput(self, action, value, change, isRepeat)
	if action == "close tab button" and change == 1 then
		local tabBar = scene:get("/root/mainColumn/mainRow/editScenePanel/VPColumn/TabBar")
		tabBar:call("closeScene", self._sceneName)
	end
end

local function _new(sceneName)
	w, h = 100, 17
	local font = new.font(unpack(fnt.default))
	local w = math.min(font:getWidth(sceneName) + 12, w)
	local self = mod(gui.Slice(tex.Tab_Normal, nil, {6, 0}, 0, 0, 0, w, h, 0, 0, 0, 0, {"zoom", "none"}, 6, 0), {children = {
		mod(gui.Mask(nil, 0, 0, 0, w, h, 0, 0, 0, 0, "fill"), {children = {
			mod(gui.Text(sceneName, fnt.default, 0, -1, 0, 1000, 1, 0, 1, 0, "right"), {layer = "text", name = "label"})
		}})
	}, script = { script }, name = sceneName, layer = "widgets", ruuinput = ruuinput})
	self.label = self.children[1].children[1]
	return self
end

return _new
