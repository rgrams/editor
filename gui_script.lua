
local script = {}

local baseX, baseY = 550, 0
local yIncr = 15

local classProperties = {
	Object = { "name", "path", "visible", "pos", "angle", "sx", "sy" }
}

function script.init(self)
	self.debugDraw = false
end

function script.showProperties(self, obj)
	self.obj = obj -- May be nil.
end

function script.draw(self)
	local o = self.obj
	if o then
		local class = o.className
		local props = classProperties[class] or classProperties.Object
		love.graphics.setColor(1, 1, 1, 1)
		for i,k in pairs(props) do
			local v = o[k]
			local s
			if type(v) == "table" then
				s = tostring(k) .. " = { "
				for _k,_v in pairs(v) do
					s = s .. tostring(_k) .. " = " .. tostring(_v) .. ", "
				end
				s = string.sub(s, 1, -3) .. " }"
			else
				s = tostring(k) .. " = " .. tostring(v)
			end
			love.graphics.print(s, baseX, baseY + i * yIncr)
		end
	end
end


return script
