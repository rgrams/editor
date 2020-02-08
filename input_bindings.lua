
-- {name, type, device, input}
local bindings = {
	{ "quit", "button", "key", "escape" },
	{ "reset", "button", "scancode", "delete" },
	{ "pause", "button", "key", "rshift" },

	{ "save object", "button", "scancode", ";" },
	{ "rename", "button", "scancode", "f2" },
	{ "set script", "button", "scancode", "s" },
	{ "text", "text", "text", "text" },
	{ "backspace", "button", "scancode", "backspace" },
	{ "confirm", "button", "scancode", "return" },

	{ "add object", "button", "scancode", "a" },
	{ "delete object", "button", "scancode", "delete" },
	{ "reparent", "button", "scancode", "r" },

	{ "left click", "button", "mouse", 1 },
	{ "snap", "button", "scancode", "lshift" },
	{ "zoom", "axis", "mouse", "wheel y" },
	{ "pan", "button", "mouse", 3 },
}

return bindings
