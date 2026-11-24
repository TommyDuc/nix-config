require("mini.diff").setup({
	view = {
		style = "number",
	},
	mappings = {
		apply = nil,
		reset = nil,
		textobject = nil,

		goto_first = "<Leader>NH",
		goto_prev = "<Leader>Nh",
		goto_next = "<Leader>nh",
		goto_last = "<Leader>nH",
	},
})

require("mini.cursorword").setup({
	delay = 350,
})

require("mini.icons").setup()

require("mini.pairs").setup()

require("mini.bracketed").setup()

require("mini.trailspace").setup()

require("mini.notify").setup()

require("mini.tabline").setup()

-- `nvim_buf_set_name` / `:file` (e.g. LSP file rename, <leader>rf) updates the
-- buffer name but doesn't mark the tabline dirty, so mini.tabline keeps
-- rendering the old label until some unrelated redraw.
vim.api.nvim_create_autocmd("BufFilePost", {
	group = vim.api.nvim_create_augroup("TommyTablineRedraw", { clear = true }),
	callback = function()
		vim.schedule(function()
			vim.cmd("redrawtabline")
		end)
	end,
	desc = "Redraw tabline after buffer rename",
})

require("mini.comment").setup()

require("mini.jump").setup({
	delay = {
		highlight = 100,
		idle_stop = 5000,
	},
})

require("mini.map").setup()
vim.keymap.set("n", "<Leader>mc", MiniMap.close)
vim.keymap.set("n", "<Leader>mf", MiniMap.toggle_focus)
vim.keymap.set("n", "<Leader>mo", MiniMap.open)
vim.keymap.set("n", "<Leader>mr", MiniMap.refresh)
vim.keymap.set("n", "<Leader>ms", MiniMap.toggle_side)
vim.keymap.set("n", "<Leader>mt", MiniMap.toggle)

local indentscope = require("mini.indentscope")
indentscope.setup({
	draw = {
		animation = indentscope.gen_animation.none(),
	},
	options = {
		indent_at_cursor = true,
		try_as_border = true,
	},
})

require("mini.splitjoin").setup({
	mappings = {
		toggle = "gS",
		split = "",
		join = "",
	},
})

local sj = require("mini.splitjoin")
local TRAILING_SEPARATOR_FILETYPES = { "go", "python" }

vim.api.nvim_create_autocmd("FileType", {
	pattern = TRAILING_SEPARATOR_FILETYPES,
	callback = function()
		vim.b.minisplitjoin_config = {
			split = { hooks_post = { sj.gen_hook.add_trailing_separator() } },
			join = { hooks_post = { sj.gen_hook.del_trailing_separator() } },
		}
	end,
})

require("mini.surround").setup({
	custom_surroundings = nil,
	highlight_duration = 500,
	mappings = {
		add = "sa",
		delete = "sd",
		find = "sf",
		find_left = "sF",
		highlight = "sh",
		replace = "sr",
		update_n_lines = "sn",
		suffix_last = "l",
		suffix_next = "n",
	},
	n_lines = 100,
	respect_selection_type = false,
	search_method = "cover",
	silent = false,
})
vim.keymap.set("n", "s", "<Nop>") -- Avoid the delay caused by the ambiguity of 's' or 'cl'

require("mini.bufremove").setup()
vim.keymap.set("n", "<leader>bd", function()
	require("mini.bufremove").delete(0, false)
end, { desc = "Delete buffer (keep window)" })
vim.keymap.set("n", "<leader>bD", function()
	require("mini.bufremove").delete(0, true) -- force, discard unsaved
end, { desc = "Force delete buffer (keep window)" })
