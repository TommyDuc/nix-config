require("videre").setup({
	round_units = false,
})

vim.keymap.set("n", "<leader>nj", ":Videre<CR>", { desc = "Open Videre graph view" })
