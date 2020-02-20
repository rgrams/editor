
local script = {}

local fnt = require "theme.fonts"

local DURATION = 1
local KEY_HEIGHT = 20
local INNER_PADDING = 5
local PADDING = 5
local ROUND = 5
local KEY_COLOR = {1, 1, 1, 0.2}
local KEY_TEXT_COLOR = {1, 1, 1, 1}

local function findKeyInList(list, device, input)
	for i,key in ipairs(list) do
		if key.device == device and key.input == input then
			return i, key
		end
	end
end

local function addNewKey(self, device, input, value)
	local text
	if device == "key" or value == 2 then
		text = string.upper(input)
	else
		text = "MOUSE " .. input
	end
	local w = self.keyFont:getWidth(text) + INNER_PADDING * 2
	local key = { device = device, input = input, text = text, w = w }
	table.insert(self.keyList, key)
	self.isInputPressed[device][input] = value
	shouldRedraw = true
	return key
end

-- Raw input happens before action input.
local function rawInput(self, device, input, value)
	if device ~= "mouse" and device ~= "key" then  return  end -- Ignore scancodes, joysticks, etc.
	if input == "wheel y" or input == "wheel x" then  value = 2  end -- Wheel is a special case - no release events.
	if value >= 1 then -- Pressed.
		local curVal = self.isInputPressed[device][input]
		if not curVal then
			local key = addNewKey(self, device, input, value)
			if value == 2 then  key.t = DURATION  end -- Start fading wheel events immediately.
		elseif curVal then
			if value == 2 or curVal ~= value then
				self.isInputPressed[device][input] = value
				local i, key = findKeyInList(self.keyList, device, input)
				key.t = nil
				shouldRedraw = true
				if input == "wheel y" or input == "wheel x" then
					key.t = DURATION -- Won't send a released event, start fading immediately.
				end
			end
		end
	elseif value == 0 then -- Released.
		local i, key = findKeyInList(self.keyList, device, input)
		key.t = DURATION -- Start it fading.
		self.isInputPressed[device][input] = value
	end
end

local function setColorWithAlphaMult(c, a)
	local r,g,b,a = c[1], c[2], c[3], c[4]*a
	love.graphics.setColor(r, g, b, a)
end

function script.init(self)
	self.input = rawInput
	Input.enable(self, true)
	self.warnings = {}
	self.commands = {}
	self.keyList = {}
	self.isInputPressed = { mouse = {}, key = {} }
	self.keyFont = new.font(unpack(fnt.default))
end

function script.update(self, dt)
	for i=#self.keyList,1,-1 do
		local key = self.keyList[i]
		if key.t then
			shouldRedraw = true
			key.t = key.t - dt
			if key.t <= 0 then
				table.remove(self.keyList, i)
				self.isInputPressed[key.device][key.input] = nil
			end
		end
	end
end

function script.draw(self)
	if #self.keyList > 0 then
		local X, Y = -self.w/2 + 10, self.h/2 - 30 - KEY_HEIGHT
		love.graphics.setFont(self.keyFont)
		for i,key in ipairs(self.keyList) do
			local colorMult = key.t and key.t/DURATION or 1
			setColorWithAlphaMult(KEY_COLOR, colorMult)
			love.graphics.rectangle("fill", X, Y, key.w, KEY_HEIGHT, ROUND)
			setColorWithAlphaMult(KEY_TEXT_COLOR, colorMult)
			love.graphics.print(key.text, X + INNER_PADDING, Y)
			X = X + key.w + PADDING
		end
	end
end

return script