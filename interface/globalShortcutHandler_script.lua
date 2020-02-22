
-- Gets input ahead of Ruu and handles global shortcuts.

local script = {}

local activeData = require "activeData"

function script.init(self)
end

function script.input(self, name, value, change)
	if name == "undo/redo" and value == 1 then
		if Input.get("lctrl").value == 1 or Input.get("rctrl").value == 1 then
			if Input.get("lshift").value == 1 or Input.get("rshift").value == 1 then
				local redoCommand, args = activeData.commands:redo()
				print("Redo: " .. tostring(redoCommand))
				if args then  for k,v in pairs(args) do  print("", k,v)  end  end
				return true -- Consume input.
			else
				local undoCommand, args = activeData.commands:undo()
				print("Undo: " .. tostring(undoCommand))
				if args then  for k,v in pairs(args) do  print("", k,v)  end  end
				return true -- Consume input.
			end
		end
	end
end

return script
