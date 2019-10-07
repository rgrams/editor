
local script = {}


function script.init(self)
	self.debugDraw = false
end

function script.showProperties(self, obj)
	self.obj = obj -- May be nil.
end

function script.draw(self)
	local o = self.obj
	if o then
		love.graphics.setColor(1, 1, 1, 1)
		local sx, sy = 600, 300
		local y = 15
		love.graphics.print("path = " .. o.path, sx, sy + y*-1)
		love.graphics.print("pos.x = " .. o.pos.x, sx, sy + y*0)
		love.graphics.print("pos.y = " .. o.pos.y, sx, sy + y*1)
		love.graphics.print("angle = " .. o.angle, sx, sy + y*2)
		love.graphics.print("scale-x = " .. o.sx, sx, sy + y*3)
		love.graphics.print("scale-y = " .. o.sy, sx, sy + y*4)
	end
end


return script
