
require "philtre.init"  -- Load all engine components into global variables.
require "philtre.lib.math-patch"
vector = require "philtre.lib.vec2xy"

physics.setCategoryNames(
	"walls", "one way platforms", "moving platforms",
	"players", "player weapons", "player sensors", "checkpoints",
	"enemies", "enemy weapons"
)
local drawLayers = {
	gui = { "gui" },
	world = { "entities", "glow", "physics debug" },
}
local defaultLayer = "entities"

local guiCam
local root
local editor_script = require "editor_script"
local gui_script = require "gui_script"

function love.load()
	Input.init()
	Input.bind(require("input_bindings"))

	scene = SceneTree(drawLayers, defaultLayer)

	-- Add GUI cam before game cam.
	local gui = { w = 1600, h = 900 }
	local gs = 2
	gui.w, gui.h = gui.w / gs, gui.h / gs
	guiCam = Camera(gui.w/2, gui.h/2, 0, gui, nil, 16/9)
	guiCam.name = "GUI Camera"
	scene:add(guiCam)

	-- Add world tree in one chunk so inits are called in bottom-up order.
	root = mod(
		Object(), { name = "root", debugDraw = false, children = {
			mod(World(0, 1800, false), { script = {editor_script}, debugDraw = false }),
			mod(Object(), { script = { gui_script }, name = "gui", layer = "gui" }),
			Camera()
		}}
	)
	scene:add(root)

	world = scene:get("/root/World")
end

function love.update(dt)
	scene:update(dt)
end

function love.draw()
   Camera.current:applyTransform()
	root:callRecursive("debugDraw", "physics debug")
   scene:draw("world")
	Camera.current:resetTransform()
	guiCam:applyTransform()
	scene:draw("gui")
	guiCam:resetTransform()

	love.graphics.setColor(1, 1, 1, 1)
   local avgDt = love.timer.getAverageDelta() * 1000
   love.graphics.print(string.format("%.4f", avgDt))
end

function love.resize(w, h)
	Camera.windowResizedAll(0, 0, w, h)
end