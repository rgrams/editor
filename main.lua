
require "philtre.init"  -- Load all engine components into global variables.
require "philtre.lib.math-patch"
vector = require "philtre.lib.vec2xy"
gui = require "philtre.gui.all"
local settings = require "settings"

require "run"

local Root = require "root"
local root

local designW, designH = love.window.getMode()

local drawLayers = {
	gui = { "gui debug", "popupText", "popupWidgets", "popupPanels", "text", "widgets", "panels" },
	viewportBackground = { "viewportBackground" },
	editScene = { "entities" },
}
local defaultLayer = "panels"

function love.load()
	Input.init()
	Input.bind(require("input_bindings"))
	love.graphics.setBackgroundColor(settings.viewportBackgroundColor)
	scene = SceneTree(drawLayers, defaultLayer)

	local rootObjects = Root(designW, designH)
	root = rootObjects[1]
	for i,obj in ipairs(rootObjects) do
		scene:add(obj)
	end
end

function love.update(dt)
	scene:update(dt)
end

function love.draw()
	Camera.current:applyTransform()
	scene:draw("viewportBackground")
   scene:draw("editScene")
	Camera.current:resetTransform()
	-- scene:callRecursive("debugDraw", "gui debug")
	scene:draw("gui")
	scene.draw_order:clear("gui debug")
end

function love.keypressed(key, scancode, isrepeat)
	if scancode == "escape" then
		love.event.quit(0)
	end
end

function love.resize(w, h)
	Camera.setAllViewports(0, 0, w, h)
	root:parentResized(designW, designH, w, h, 1)
	shouldRedraw = true
end

function love.focus(focus)
	if focus then  shouldRedraw = true  end
end

function love.mousemoved(x, y, dx, dy, istouch)
	if love.window.hasFocus() then
		shouldRedraw = true
	end
end
