
local script = {}

local fnt = require "theme.fonts"

local DURATION = 3
local BASE_X, BASE_Y = 0, 70
local SHAPE_HEIGHT = 29
local INNER_PADDING = 5
local PADDING = 2
local ROUND = 4
local SHAPE_COLOR = {0.2, 1, 0.5, 0.3}
local TEXT_COLOR = {1, 1, 1, 1}

function script.init(self)
	self.font = new.font(unpack(fnt.keyCast))
	self.msgList = {}
end

local function newMessage(text, font, msgType)
	local w = font:getWidth(text) + INNER_PADDING * 2
	return { text = text, msgType = msgType, t = DURATION, w = w }
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

function script.draw(self)
	if #self.msgList > 0 then
		local X, Y = BASE_X, -self.h/2 + BASE_Y
		love.graphics.setFont(self.font)
		for i=#self.msgList,1,-1 do
			local msg = self.msgList[i]
			local x = X - msg.w/2
			local colorMult = msg.t and msg.t/DURATION or 1
			setColorWithAlphaMult(SHAPE_COLOR, colorMult)
			love.graphics.rectangle("fill", x, Y, msg.w, SHAPE_HEIGHT, ROUND)
			setColorWithAlphaMult(TEXT_COLOR, colorMult)
			love.graphics.print(msg.text, x + INNER_PADDING, Y + 1)
			Y = Y - (SHAPE_HEIGHT + PADDING)
		end
	end
end

return script
