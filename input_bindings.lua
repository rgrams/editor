
-- {name, type, device, input}
local bindings = {
	{ "quit", "button", "scancode", "`" },
	{ "reset", "button", "scancode", "delete" },
	{ "pause", "button", "key", "rshift" },

	{ "up", "button", "scancode", "up" },
	{ "down", "button", "scancode", "down" },
	{ "left", "button", "scancode", "left" },
	{ "right", "button", "scancode", "right" },

	{ "scroll x", "axis", "mouse", "wheel x" },
	{ "scroll y", "axis", "mouse", "wheel y" },

	{ "lshift", "button", "scancode", "lshift" },
	{ "rshift", "button", "scancode", "rshift" },
	{ "lctrl", "button", "scancode", "lctrl" },
	{ "rctrl", "button", "scancode", "rctrl" },

	{ "undo/redo", "button", "key", "z" },

	{ "save object", "button", "scancode", ";" },
	{ "rename", "button", "scancode", "f2" },
	{ "set script", "button", "scancode", "s" },
	{ "text", "text", "text", "text" },
	{ "backspace", "button", "scancode", "backspace" },
	{ "confirm", "button", "scancode", "return" },
	{ "cancel", "button", "scancode", "escape" },

	{ "add object", "button", "scancode", "a" },
	{ "remove object", "button", "scancode", "delete" },
	{ "reparent", "button", "scancode", "r" },

	{ "left click", "button", "mouse", 1 },
	{ "snap", "button", "scancode", "lshift" },
	{ "zoom", "axis", "mouse", "wheel y" },
	{ "pan", "button", "mouse", 3 },
}

return bindings
