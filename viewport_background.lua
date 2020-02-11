
local script = {}

local snapIncrement = 8
local desiredMaxGridLines = 48
local bigGridEvery = 4
local gridNumberScale = 1
local gridColor = { 0.5, 0.5, 0.5, 0.35 }
local bigGridColor = { 0.5, 0.5, 0.5, 0.55 }
local gridNumberColor = { 0.7, 0.7, 0.7, 1 }
local axisColor = { 0.8, 0.8, 0.8, 0.6 }

local viewportPath = "/root/mainColumn/mainRow/viewport"

function script.init(self)
	self.vpNode = scene:get(viewportPath)
end

local function getSmallestPowerOf2(x)
	local count = 0
	while math.ceil(x) > 1.99 do
		x = x / 2
		count = count + 1
	end
	return count
end

function script.draw(self)
	local vp = self.vpNode
	local scrTLX, scrTLY = vp:toWorld(-vp.w/2, -vp.h/2)
	local scrBRX, scrBRY = vp:toWorld(vp.w/2, vp.h/2)

	local tlx, tly = Camera.current:screenToWorld(scrTLX, scrTLY)
	local brx, bry = Camera.current:screenToWorld(scrBRX, scrBRY)
	local w, h = brx - tlx, bry - tly

	local scale = 1 / Camera.current.zoom
	love.graphics.setLineWidth(scale)
	local numScale = scale * gridNumberScale

	-- Draw grid to fill screen.
	local larger = math.max(w, h)
	local k = larger / desiredMaxGridLines / snapIncrement
	local power = getSmallestPowerOf2(k)
	local viewSnapIncr = snapIncrement * math.pow(2, power)

	local numSpacing = viewSnapIncr / 12

	local xcount, ycount = math.ceil(w / viewSnapIncr), math.ceil(h / viewSnapIncr)
	local roundTop = math.round(tly / viewSnapIncr) * viewSnapIncr
	local roundLeft = math.round(tlx / viewSnapIncr) * viewSnapIncr
	for i=1,ycount do
		local y = roundTop + (i-1)*viewSnapIncr
		if y/viewSnapIncr % bigGridEvery == 0 then
			love.graphics.setColor(gridNumberColor)
			love.graphics.print(y, 0 + numSpacing, y + numSpacing, 0, numScale, numScale)
			love.graphics.print(y, tlx + numSpacing, y + numSpacing, 0, numScale, numScale)
			love.graphics.setColor(bigGridColor)
		else
			love.graphics.setColor(gridColor)
		end
		love.graphics.line(tlx, y, brx, y)
	end
	for i=1,xcount do
		local x = roundLeft + (i-1)*viewSnapIncr
		if x/viewSnapIncr % bigGridEvery == 0 then
			love.graphics.setColor(gridNumberColor)
			love.graphics.print(x, x + numSpacing, 0 + numSpacing, 0, numScale, numScale)
			love.graphics.print(x, x + numSpacing, bry - 24*numScale + numSpacing, 0, numScale, numScale)
			love.graphics.setColor(bigGridColor)
		else
			love.graphics.setColor(gridColor)
		end
		love.graphics.line(x, tly, x, bry)
	end

	-- Draw origin axis lines.
	love.graphics.setColor(axisColor)
	love.graphics.line(0, tly, 0, bry)
	love.graphics.line(tlx, 0, brx, 0)

	love.graphics.setLineWidth(1)
end

return script