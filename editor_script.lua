
local script = {}

local hitDist = 20
local snapIncrement = 8
local zoomRate = 0.1
local desiredMaxGridLines = 48
local bigGridEvery = 4
local gridNumberScale = 1
local gridColor = { 0.5, 0.5, 0.5, 0.35 }
local bigGridColor = { 0.5, 0.5, 0.5, 0.55 }
local gridNumberColor = { 0.7, 0.7, 0.7, 1 }
local axisColor = { 0.8, 0.8, 0.8, 0.6 }

function script.init(self)
	Input.enable(self)
	self.msx, self.msy = 0, 0
	self.mwx, self.mwy = 0, 0
	self.lastmwx, self.lastmwy = 0, 0
	self.lastmsx, self.lastmsy = 0, 0
	self.first = true
end

local function getObjList(self, obj)
	if obj.children then
		for i,child in ipairs(obj.children) do
			getObjList(self, child)
			table.insert(self.objList, child)
		end
	end
end

function script.update(self, dt)
	if self.first then
		self.gui = scene:get("/root/gui")
		self.first = false
	end

	self.msx, self.msy = love.mouse.getPosition()
	self.mwx, self.mwy = Camera.current:screenToWorld(self.msx, self.msy)

	if not self.drag then
		self.hoverList = {}
		self.objList = {}
		getObjList(self, world)
		for i,obj in ipairs(self.objList) do
			local dist = vector.dist(self.mwx, self.mwy, obj.pos.x, obj.pos.y)
			if dist < hitDist then
				self.hoverList[obj] = { x = obj.pos.x - self.mwx, y = obj.pos.y - self.mwy }
			end
		end
	else -- Drag.
		local obj,offset = next(self.hoverList)
		if obj then
			local x, y = self.mwx + offset.x, self.mwy + offset.y
			if Input.get("snap").value == 1 then
				x = math.round(x, snapIncrement)
				y = math.round(y, snapIncrement)
			end
			obj.pos.x, obj.pos.y = x, y
		end
	end

	self.gui:call("showProperties", next(self.hoverList))

	if self.panning then
		local dx, dy = self.msx - self.lastmsx, self.msy - self.lastmsy
		dx, dy = Camera.current:screenToWorld(dx, dy, true)
		local camPos = Camera.current.pos
		camPos.x, camPos.y = camPos.x - dx, camPos.y - dy
	end

	self.lastmsx, self.lastmsy = self.msx, self.msy
	self.lastmwx, self.lastmwy = self.mwx, self.mwy
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
	local o = next(self.hoverList)
	if o then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.circle("line", o.pos.x, o.pos.y, 20, 16)
	end

	local tlx, tly = Camera.current:screenToWorld(0, 0)
	local winw, winh = love.window.getMode()
	local brx, bry = Camera.current:screenToWorld(winw, winh)
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

function script.input(self, name, value, change)
	if name == "quit" then
		love.event.quit(0)
	elseif name == "add object" and change == 1 then
		scene:add(Object(self.mwx, self.mwy), world)
	elseif name == "left click" then
		if change == 1 then
			self.drag = true
		elseif change == -1 then
			self.drag = nil
		end
	elseif name == "zoom" then
		Camera.current:zoomIn(value * zoomRate)
	elseif name == "pan" then
		if value == 1 then
			self.panning = { x = Camera.current.pos.x, y = Camera.current.pos.y }
		else
			self.panning = nil
		end
	end
end


return script
