
-- Gets input ahead of Ruu and handles global shortcuts.

local script = {}

local activeData = require "activeData"

function script.ruuinput(self, name, value, change)
	if name == "redo" and value == 1 then
		local redoCommand, args = activeData.commands:redo()
		local messager = scene:get("/root/overlay")

		local msg
		if not redoCommand then  msg = "No commands to Redo"
		else  msg = "Redo: "..tostring(redoCommand)  end

		messager:call("message", msg)
		return true -- Consume input.
	elseif name == "undo" and value == 1 then
		local undoCommand, args = activeData.commands:undo()

		local msg
		if not undoCommand then  msg = "No commands to Undo"
		else  msg = "Undo: "..tostring(undoCommand)  end

		local messager = scene:get("/root/overlay")
		messager:call("message", msg)
		return true -- Consume input.
	end
end

return script
