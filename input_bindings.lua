
local bindings = {
	{ "button", "`", "quit" },
	{ "button", "escape", "cancel" },

	{ "mouseMoved", "mouseMoved" },

	{ "button", "m:1", "left click" },
	{ "button", "enter", "enter" },
	{ "button", "up", "up" },
	{ "button", "down", "down" },
	{ "button", "left", "left" },
	{ "button", "right", "right" },
	{ "button", "tab", "next" },
	{ "button", "shift tab", "prev" },
	{ "button", "home", "home" },
	{ "button", "end", "end" },

	{ "button", "m:4", "back" },
	{ "button", "m:5", "forward" },

	{ "axis", "m:wheelx-", "m:wheelx+", "scrollx" },
	{ "axis", "m:wheely-", "m:wheely+", "scrolly" },

	{ "button", "ctrl k:z", "undo" },
	{ "button", "ctrl shift k:z", "redo" },
	{ "button", "ctrl k:x", "cut" },
	{ "button", "ctrl k:c", "copy" },
	{ "button", "ctrl k:v", "paste" },
	{ "button", "ctrl k:s", "save" },
	{ "button", "ctrl k:o", "open" },

	{ "text", "text" },
	{ "button", "backspace", "backspace" },
	{ "button", "delete", "delete" },

	{ "button", "shift a", "add object" },
	{ "button", "delete", "remove object" },

	{ "button", "m:3", "pan" },
	{ "axis", "m:wheely-", "m:wheely+", "zoom" },

	{ "button", "ctrl", "shift" },
	{ "button", "shift", "shift" },
	{ "button", "alt", "shift" },

	{ "button", "f2", "test" },
}

return bindings
