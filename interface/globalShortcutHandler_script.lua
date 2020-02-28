
-- Gets input ahead of Ruu and handles global shortcuts.

local script = {}

local activeData = require "activeData"

function script.init(self)
end

function script.input(self, name, value, change)
	if name == "redo" and value == 1 then
		local redoCommand, args = activeData.commands:redo()
		print("Redo: " .. tostring(redoCommand))
		if args then  for k,v in pairs(args) do  print("", k,v)  end  end
		return true -- Consume input.
	elseif name == "undo" and value == 1 then
		local undoCommand, args = activeData.commands:undo()
		print("Undo: " .. tostring(undoCommand))
		if args then  for k,v in pairs(args) do  print("", k,v)  end  end
		return true -- Consume input.
	end
end

return script
