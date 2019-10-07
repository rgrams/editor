
-- {name, type, device, input}
local bindings = {
	{ "quit", "button", "key", "escape" },
	{ "reset", "button", "scancode", "delete" },
	{ "pause", "button", "key", "rshift" },

	{ "add object", "button", "scancode", "a" },
	{ "left click", "button", "mouse", 1 },
	{ "snap", "button", "scancode", "lshift" },
	{ "zoom", "axis", "mouse", "wheel y" },
	{ "pan", "button", "mouse", 3 },
}

return bindings
