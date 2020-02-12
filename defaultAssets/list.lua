
local M = {}

-- Sprite & Quad image
M.image = new.image("defaultAssets/NoSprite.png")
-- Text font
M.font = {"theme/font/OpenSans-Regular.ttf", 12}
-- Quad quad
do
	local iw, ih = M.image:getDimensions()
	M.quad = love.graphics.newQuad(0, 0, iw, ih, iw, ih)
end

return M
