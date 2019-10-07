
local script = {}

local parser = require "parser"

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

local function getObjList(self, obj, list)
	list = list or {}
	if obj.children then
		for i,child in ipairs(obj.children) do
			getObjList(self, child, list)
			table.insert(list, child)
		end
	end
	return list
end

local function refreshHoverList(self, except)
	self.hoverList = {}
	local objList = getObjList(self, world)
	for i,obj in ipairs(objList) do
		if obj ~= except then
			local ox, oy = obj:toWorld(0, 0)
			local dist = vector.dist(self.mwx, self.mwy, ox, oy)
			if dist < hitDist then
				local mlx, mly = obj:toLocal(self.mwx, self.mwy)
				self.hoverList[obj] = { x = mlx, y = mly }
			end
		end
	end
end

function script.update(self, dt)
	if self.first then
		self.gui = scene:get("/root/gui")
		self.gui.editor = self
		self.first = false
	end

	self.msx, self.msy = love.mouse.getPosition()
	self.mwx, self.mwy = Camera.current:screenToWorld(self.msx, self.msy)

	if not self.drag and not self.isTyping then
		refreshHoverList(self)
		self.obj, self.lastDragLPos = next(self.hoverList)
	elseif self.drag then -- Drag.
		local obj,last = self.obj, self.lastDragLPos
		if obj then
			local wx, wy = self.mwx, self.mwy
			lx, ly = obj:toLocal(wx, wy)
			local ldx, ldy = lx - last.x, ly - last.y
			obj.pos.x, obj.pos.y = obj.pos.x + ldx, obj.pos.y + ldy
			-- Snap local position.
			if Input.get("snap").value == 1 then
				obj.pos.x = math.round(obj.pos.x, snapIncrement)
				obj.pos.y = math.round(obj.pos.y, snapIncrement)
			end
		end
	end

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
	local o = self.obj
	if o then
		love.graphics.setColor(1, 1, 1, 1)
		local x, y = o:toWorld(0, 0)
		love.graphics.circle("line", x, y, 20, 16)
	end

	if self.isReparenting then
		local x, y = self.objToReparent:toWorld(0, 0)
		love.graphics.setColor(0, 0.7, 1, 0.6)
		love.graphics.circle("line", x, y, 15, 16)
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

local function reparent(self)
	if self.obj ~= self.objToReparent then
		local targetParent = self.obj or world
		if self.objToReparent ~= targetParent.parent then -- Don't parent object to its own child.
			scene:setParent(self.objToReparent, targetParent, true)
		end
	end
end

function script.input(self, name, value, change)
	if self.isTyping then
		if name == "text" then
			self.text = self.text .. value
		elseif name == "backspace" then
			self.text = string.sub(self.text, 1, -2)
		elseif name == "confirm" then
			self.isTyping = false
			self.obj.name = self.text
		elseif name == "quit" and change == 1 then
			self.isTyping = false
		end
	else
		if name == "add object" and change == 1 then
			scene:add(Object(self.mwx, self.mwy), world)
		elseif name == "save object" and change == 1 then
			if self.obj then  parser.encode(self.obj)  end
		elseif name == "delete object" and change == 1 then
			if self.obj then
				scene:remove(self.obj)
				self.obj = nil
			end
		elseif name == "reparent" then
			if change == 1 and self.obj and not self.drag then
				self.isReparenting = true
				self.objToReparent = self.obj
			elseif change == -1 then
				if self.isReparenting then  reparent(self)  end
				self.isReparenting = false
				self.objToReparent = nil
			end
		elseif name == "rename" and change == 1 then
			if self.obj then
				self.isTyping = true
				self.text = ""
			end
		elseif name == "left click" then
			if change == 1 then
				if self.isReparenting then
					reparent(self)
					self.isReparenting = false
					self.objToReparent = nil
				else
					self.drag = true
				end
			elseif change == -1 then
				self.drag = nil
				self.dropTarget = nil
			end
		elseif name == "zoom" then
			Camera.current:zoomIn(value * zoomRate)
		elseif name == "pan" then
			if value == 1 then
				self.panning = { x = Camera.current.pos.x, y = Camera.current.pos.y }
			else
				self.panning = nil
			end
		elseif name == "quit" and change == 1 then
			love.event.quit(0)
		end
	end
end


return script
