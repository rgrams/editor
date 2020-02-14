
local sceneCommands = require "commands.scene-commands"
local selectionCommands = require "commands.selection-commands"

local list = {sceneCommands, selectionCommands}

local all = {}

for i,commList in ipairs(list) do
	for k,v in pairs(commList) do
		all[k] = v
	end
end

return all
