
-- {name, type, device, input}
local bindings = {
	{ "quit", "button", "scancode", "`" },
	{ "pause", "button", "key", "rshift" },

	{ "up", "button", "scancode", "up" },
	{ "down", "button", "scancode", "down" },
	{ "left", "button", "scancode", "left" },
	{ "right", "button", "scancode", "right" },

	{ "next", "button", "key", "tab" },

	{ "back", "button", "mouse", 4 },

	{ "scroll x", "axis", "mouse", "wheel x" },
	{ "scroll y", "axis", "mouse", "wheel y" },

	{ "lshift", "button", "scancode", "lshift" },
	{ "rshift", "button", "scancode", "rshift" },
	{ "lctrl", "button", "scancode", "lctrl" },
	{ "rctrl", "button", "scancode", "rctrl" },
	{ "lalt", "button", "scancode", "lalt" },
	{ "ralt", "button", "scancode", "ralt" },

	{ "undo/redo", "button", "key", "z" },
	{ "copy", "button", "key", "c" },
	{ "cut", "button", "key", "x" },
	{ "paste", "button", "key", "v" },

	{ "save", "button", "key", "s" },
	{ "rename", "button", "scancode", "f2" },
	{ "text", "text", "text", "text" },
	{ "backspace", "button", "scancode", "backspace" },
	{ "delete", "button", "scancode", "delete" },
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
