require("coerce").setup({
	keymap_registry = require("coerce.keymap").keymap_registry(),
	-- The notification function used during error conditions.
	notify = function(...)
		return vim.notify(...)
	end,
	default_mode_keymap_prefixes = {
		normal_mode = "<leader>cr",
		motion_mode = "<leader>gcr",
		visual_mode = "<leader>gcr",
	},
	-- Set any field to false to disable that mode.
	default_mode_mask = {
		normal_mode = true,
		motion_mode = true,
		visual_mode = true,
	},
})
