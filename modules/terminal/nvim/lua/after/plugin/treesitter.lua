-- Start native treesitter highlighting whenever a grammar exists for the filetype
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("TommyTreesitter", { clear = true }),
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
	},
})

local select_to = require("nvim-treesitter-textobjects.select").select_textobject

vim.keymap.set({ "x", "o" }, "if", function()
	select_to("@function.inner", "textobjects")
end, { desc = "Select inner function" })
vim.keymap.set({ "x", "o" }, "af", function()
	select_to("@function.outer", "textobjects")
end, { desc = "Select outer function" })
vim.keymap.set({ "x", "o" }, "ic", function()
	select_to("@class.inner", "textobjects")
end, { desc = "Select inner class" })
vim.keymap.set({ "x", "o" }, "ac", function()
	select_to("@class.outer", "textobjects")
end, { desc = "Select outer class" })
