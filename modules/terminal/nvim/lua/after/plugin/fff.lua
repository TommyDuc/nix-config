local fff = require("fff")

fff.setup({
	base_path = vim.fn.getcwd(),
	prompt = "🖕 ",
	title = "FFFiles",
	max_results = 100,
	max_threads = 4,
	lazy_sync = true,
	layout = {
		height = 1,
		width = 1,
		prompt_position = "top",
		preview_position = "bottom",
		preview_size = 0.7,
	},
	preview = {
		enabled = true,
		max_size = 10 * 1024 * 1024,
		chunk_size = 8192,
		binary_file_threshold = 1024,
		imagemagick_info_format_str = "%m: %wx%h, %[colorspace], %q-bit",
		line_numbers = true,
		wrap_lines = true,
		show_file_info = true,
		filetypes = {
			svg = { wrap_lines = true },
			markdown = { wrap_lines = true },
			text = { wrap_lines = true },
		},
	},
	keymaps = {
		close = { "<C-c>", "<Esc>" },
		select = "<CR>",
		select_split = "<C-s>",
		select_vsplit = "<C-v>",
		select_tab = "<C-t>",
		move_up = { "<Up>", "<C-p>" },
		move_down = { "<Down>", "<C-n>" },
		preview_scroll_up = "<C-u>",
		preview_scroll_down = "<C-d>",
		toggle_debug = "<F2>",
	},
	hl = {
		border = "FloatBorder",
		normal = "Normal",
		cursor = "CursorLine",
		matched = "IncSearch",
		title = "Title",
		prompt = "Question",
		active_file = "Visual",
		frecency = "Number",
		debug = "Comment",
	},
	frecency = {
		enabled = true,
		db_path = vim.fn.stdpath("cache") .. "/fff_nvim",
	},
	debug = {
		enabled = false,
		show_scores = false,
	},
	logging = {
		enabled = false,
		log_file = vim.fn.stdpath("log") .. "/fff.log",
		log_level = "info",
	},
})

vim.keymap.set("n", "<leader>ff", function()
	fff.find_files()
end, { desc = "Open file picker" })
vim.keymap.set("n", "<leader>fg", function()
	fff.find_in_git_root()
end, { desc = "Open git tracked file picker" })
vim.keymap.set("n", "<leader>fs", function()
	fff.live_grep()
end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fr", function()
	fff.live_grep({ resume = true })
end, { desc = "Resume last live grep" })
