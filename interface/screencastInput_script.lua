
local script = {}

local fnt = require "theme.fonts"

local DURATION = 3
local BASE_X, BASE_Y = 100, 30
local KEY_HEIGHT = 29
local INNER_PADDING = 5
local PADDING = 5
local ROUND = 8
local KEY_COLOR = {1, 1, 1, 0.3}
local KEY_COLOR_OFF = {0.1, 0.1, 0.1, 0.5}
local KEY_TEXT_COLOR = {1, 1, 1, 1}
local SQUISH_THRESHOLD = 0.4
local WHEEL = {}

local function findKeyInList(list, device, input)
	for i,key in ipairs(list) do
		if key.device == device and key.input == input then
			return i, key
		end
	end
end

local function addNewKey(self, device, input, value)
	local text
	if device == "key" or value == WHEEL then
		text = string.upper(input)
	else
		text = "MOUSE " .. input
	end
	local w = self.keyFont:getWidth(text) + INNER_PADDING * 2
	local key = { device = device, input = input, text = text, w = w, squish = 1 }
	table.insert(self.keyList, key)
	self.pressCount[device][input] = value
	shouldRedraw = true
	return key
end

local conversions = {
	lshift = "shift", rshift = "shift", lctrl = "ctrl", rctrl = "ctrl",
	lalt = "alt", ralt = "alt"
}

-- Raw input happens before action input.
local function rawInput(self, device, input, value, isRepeat)
	if isRepeat then  return  end
	if device ~= "mouse" and device ~= "key" then  return  end -- Ignore scancodes, joysticks, etc.
	if input == "wheely" or input == "wheelx" then  value = WHEEL -- Wheel is a special case - no release events.
	elseif conversions[input] then  input = conversions[input]  end

	local curVal = self.pressCount[device][input]
	if value ~= 0 then -- Pressed.
		if not curVal then
			local key = addNewKey(self, device, input, value)
			-- No wheel release events, so start fading them immediately.
			if value == WHEEL then  key.t = DURATION + 0.1  end -- Add a bit so it looks pressed for a few frames.
		elseif curVal then -- Event reoccured while it was still fading. (NOT a key-repeat - they already got thrown out.)
			self.pressCount[device][input] = value == WHEEL and value or curVal + 1
			local i, key = findKeyInList(self.keyList, device, input)
			key.t, key.squish = nil, 1
			shouldRedraw = true
			if value == WHEEL then  key.t = DURATION + 0.1  end
			-- Move it to the end of the list.
			table.remove(self.keyList, i)
			table.insert(self.keyList, key)
		end
	elseif value == 0 then -- Released.
		local curVal = self.pressCount[device][input]
		curVal = curVal - 1
		if curVal <= 0 then
			local i, key = findKeyInList(self.keyList, device, input)
			key.t = DURATION -- Start it fading.
		end
		self.pressCount[device][input] = curVal
	end
end

local function setColorWithAlphaMult(c, a)
	local r,g,b,a = c[1], c[2], c[3], c[4]*a
	love.graphics.setColor(r, g, b, a)
end

function script.init(self)
	self.input = rawInput
	Input.enableRaw(self)
	self.keyList = {}
	self.pressCount = { mouse = {}, key = {} }
	self.keyFont = new.font(unpack(fnt.keyCast))
	self.extraSpace = 0
end

local function inOutCubic(k)
	k = k * 2
	if k < 1 then
		return 0.5 * k*k*k -- curved 0.5-0
	else -- 2-1
		k = 2 - k -- 0-1 -- subtract 1 and flip in one operation.
		k = k*k*k -- curved 0-1
		k = 1 - k
		return 0.5 + 0.5 * k -- curved 1-0.5
	end
end

function script.update(self, dt)
	for i=#self.keyList,1,-1 do
		local key = self.keyList[i]
		if key.t then
			shouldRedraw = true
			key.t = key.t - dt
			-- Calculate squish factor.
			local k = key.t / DURATION
			if k <= SQUISH_THRESHOLD then
				k = k / SQUISH_THRESHOLD
				k = inOutCubic(k)
				key.squish = k
			end
			if key.t <= 0 then
				table.remove(self.keyList, i)
				self.pressCount[key.device][key.input] = nil
			end
		end
	end
end

function script.draw(self)
	if #self.keyList > 0 then
		local X, Y = -self.w/2 + BASE_X, self.h/2 - BASE_Y - KEY_HEIGHT
		love.graphics.setFont(self.keyFont)
		for i=#self.keyList,1,-1 do
			local key = self.keyList[i]
			local colorMult = key.t and key.t/DURATION or 1
			local keyCol = colorMult < 1 and KEY_COLOR_OFF or KEY_COLOR
			setColorWithAlphaMult(keyCol, colorMult)
			love.graphics.rectangle("fill", X, Y, key.w, KEY_HEIGHT, ROUND)
			setColorWithAlphaMult(KEY_TEXT_COLOR, colorMult)
			love.graphics.print(key.text, X + INNER_PADDING, Y + 1)
			Y = Y - (KEY_HEIGHT + PADDING) * key.squish
		end
	end
end

return script
