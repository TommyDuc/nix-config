require("gitlinker").setup({
	-- ~/.ssh/config maps bitbucket.org -> ssh.bitbucket.org, which gitlinker resolves via `ssh -G`
	router = {
		browse = {
			["^ssh%.bitbucket%.org"] = "https://bitbucket.org/"
				.. "{_A.ORG}/{_A.REPO}/src/{_A.REV}/{_A.FILE}"
				.. "#lines-{_A.LSTART}"
				.. "{(_A.LEND > _A.LSTART and (':' .. _A.LEND) or '')}",
		},
		blame = {
			["^ssh%.bitbucket%.org"] = "https://bitbucket.org/"
				.. "{_A.ORG}/{_A.REPO}/annotate/{_A.REV}/{_A.FILE}"
				.. "#lines-{_A.LSTART}"
				.. "{(_A.LEND > _A.LSTART and (':' .. _A.LEND) or '')}",
		},
	},
})

vim.keymap.set({ "n", "v" }, "<leader>gy", "<cmd>GitLink<cr>", { desc = "Yank git link on remote" })
vim.keymap.set({ "n", "v" }, "<leader>gY", "<cmd>GitLink!<cr>", { desc = "Open git link on remote" })
vim.keymap.set({ "n", "v" }, "<leader>gb", "<cmd>GitLink blame<cr>", { desc = "Yank git blame on remote" })
vim.keymap.set({ "n", "v" }, "<leader>gB", "<cmd>GitLink! blame<cr>", { desc = "Open git blame on remote" })
