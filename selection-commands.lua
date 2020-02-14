
local Selection = require "Selection"

return {
	addToSelection = { Selection.add, Selection.remove },
	removeFromSelection = { Selection.remove, Selection.add },
	toggleObjSelection = { Selection.toggle, Selection.toggle },
	clearSelection = { Selection.clear, Selection._set },
	setSelectionTo = { Selection.setTo, Selection._set }
}
