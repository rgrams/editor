
local script = {}

local objToString = require "philtre.lib.object-to-string"
local classProperties = require "class-properties"

local baseX, baseY = 550, 0
local yIncr = 15

function script.init(self)
	self.debugDraw = false
end

function script.draw(self)
	local o = self.editor.obj -- set by editor on first update
	if o then
		local class = o.className
		local props = classProperties[class] or classProperties.Object
		love.graphics.setColor(1, 1, 1, 1)
		for i,k in pairs(props) do
			local v = o[k]
			local s
			s = string.format("%s = %s", k, objToString(v))
			love.graphics.print(s, baseX, baseY + i * yIncr)
		end

		if self.editor.isTyping then
			love.graphics.print("RENAMING OBJECT - press 'enter' to confirm, 'esc' to cancel.", 300, 180)
			love.graphics.print(self.editor.text, 300, 200)
		end
	end
	if self.editor.isReparenting then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print("REPARENTING OBJECT", 300, 200)
	end
end

return script
