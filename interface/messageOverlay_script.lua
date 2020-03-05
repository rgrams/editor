
local script = {}

local fnt = require "theme.fonts"

local DEFAULT_DURATION = 3
local BASE_X, BASE_Y = 0, 70
local SHAPE_HEIGHT = 29
local INNER_PADDING_X = 8
local PADDING = 2
local ROUND = 12
local DEFAULT_SHAPE_COLOR = {0.4, 0.75, 0.5, 0.3}
local TEXT_COLOR = {1, 1, 1, 1}
local WARNING_INDENT = 10

local DURATION = {
	error = 15,
	warning = 5
}

local COLOR = {
	error = {1, 0, 0, 0.7},
	warning = {1, 0.5, 0, 0.3}
}

function script.init(self)
	self.font = new.font(unpack(fnt.overlayMsg))
	self.msgList = {}
end

local function newMessage(text, font, msgType)
	local t = DURATION[msgType] or DEFAULT_DURATION
	return {
		text = text,
		type = msgType,
		color = COLOR[msgType] or DEFAULT_SHAPE_COLOR,
		w = font:getWidth(text) + INNER_PADDING_X * 2,
		t = t,
		dur = t
	}
end

function script.message(self, text, msgType)
	table.insert(self.msgList, newMessage(text, self.font, msgType))
end

function script.update(self, dt)
	for i=#self.msgList,1,-1 do
		local msg = self.msgList[i]
		if msg.t then
			shouldRedraw = true
			msg.t = msg.t - dt
			if msg.t <= 0 then
				table.remove(self.msgList, i)
			end
		end
	end
end

local function setColorWithAlphaMult(c, a)
	local r,g,b,a = c[1], c[2], c[3], c[4]*a
	love.graphics.setColor(r, g, b, a)
end

local function drawShape(msg, x, y)
	if msg.type == "warning" then
		love.graphics.rectangle("fill", x, y, msg.w, SHAPE_HEIGHT)
	elseif msg.type == "error" then
		local w2, h2 = msg.w/2, SHAPE_HEIGHT/2
		local ind = WARNING_INDENT
		local lt, rt, top, bot = x - ind, x + msg.w + ind, y, y + SHAPE_HEIGHT
		love.graphics.polygon("fill", lt, top, rt, top, rt-ind, top+h2, lt+ind, top+h2, lt, top)
		love.graphics.polygon("fill", lt, bot, lt+ind, top+h2, rt-ind, top+h2, rt, bot, lt, bot)
	else
		love.graphics.rectangle("fill", x, y, msg.w, SHAPE_HEIGHT, ROUND)
	end
end

function script.draw(self)
	if #self.msgList > 0 then
		local X, Y = BASE_X, -self.h/2 + BASE_Y
		love.graphics.setFont(self.font)
		for i=#self.msgList,1,-1 do
			local msg = self.msgList[i]
			local x = X - msg.w/2
			local colorMult = msg.t and msg.t/msg.dur or 1
			setColorWithAlphaMult(msg.color, colorMult)
			drawShape(msg, x, Y)
			setColorWithAlphaMult(TEXT_COLOR, colorMult)
			love.graphics.print(msg.text, x + INNER_PADDING_X, Y + 2)
			Y = Y - (SHAPE_HEIGHT + PADDING)
		end
	end
end

return script
