local keyset = vim.keymap.set

-- ============================================================================
-- Completion & Signature Help (blink.cmp) — strictly manual-only (no popups!)
-- ============================================================================
local blink = require("blink.cmp")

local function has_words_before()
	local col = vim.fn.col(".") - 1
	return col > 0 and vim.fn.getline("."):sub(col, col):match("%s") == nil
end

blink.setup({
	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},
	appearance = {
		nerd_font_variant = "mono",
		kind_icons = {
			Text = "s",
			Method = "m",
			Function = "f",
			Constructor = "c",
			Field = "m",
			Variable = "V",
			Class = "C",
			Interface = "I",
			Module = "P",
			Property = "M",
			Unit = "U",
			Value = "v",
			Enum = "E",
			Keyword = "l",
			Snippet = "S",
			Color = "v",
			File = "F",
			Reference = "r",
			Folder = "D",
			EnumMember = "e",
			Constant = "C",
			Struct = "S",
			Event = "E",
			Operator = "O",
			TypeParameter = "T",
		},
	},
	completion = {
		-- "Praise be the anti-popup Omnissiah!" — never auto-trigger while typing.
		trigger = {
			prefetch_on_insert = false,
			show_in_snippet = false,
			show_on_keyword = false,
			show_on_backspace = false,
			show_on_backspace_in_keyword = false,
			show_on_backspace_after_accept = false,
			show_on_backspace_after_insert_enter = false,
			show_on_trigger_character = false,
			show_on_insert = false,
			show_on_accept_on_trigger_character = false,
			show_on_insert_on_trigger_character = false,
		},
		list = {
			selection = {
				preselect = true,
				auto_insert = false,
			},
		},
		menu = {
			auto_show = true,
			border = "single",
			draw = {
				columns = {
					{ "kind_icon" },
					{ "label", "label_description", gap = 1 },
					{ "source_name" },
				},
			},
		},
		documentation = {
			auto_show = true,
			window = {
				border = "single",
			},
		},
		ghost_text = {
			enabled = true,
		},
	},
	signature = {
		enabled = true,
		window = {
			border = "single",
			direction_priority = { "n", "s" },
		},
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	keymap = {
		preset = "none",
		["<Tab>"] = {
			function(cmp)
				if cmp.is_visible() then
					return cmp.select_next()
				elseif has_words_before() then
					return cmp.show()
				end
			end,
			"fallback",
		},
		["<S-Tab>"] = { "select_prev", "fallback" },
		["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
		["<CR>"] = { "accept", "fallback" },
		["<C-j>"] = { "snippet_forward", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-e>"] = { "hide", "fallback" },
	},
})

-- gopls appends a trailing comma to struct field completions,
-- leaving the cursor before it. Skip over instead of inserting a duplicate.
keyset("i", ",", function()
	local column = vim.fn.col(".")
	local line = vim.fn.getline(".")
	if line:sub(column, column) ~= "," then
		return ","
	end
	if line:sub(column + 1):match("^%s*$") then
		return "<Right><CR>"
	end
	return "<Right>"
end, { silent = true, noremap = true, expr = true, replace_keycodes = true })

-- ============================================================================
-- Diagnostics
-- ============================================================================
vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	virtual_text = false,
	virtual_lines = true,
	jump = {
		float = true,
	},
	float = {
		border = "single",
		source = true,
	},
})

keyset("n", "[g", function()
	vim.diagnostic.jump({ count = -1 })
end, { silent = true, desc = "Previous diagnostic" })
keyset("n", "]g", function()
	vim.diagnostic.jump({ count = 1 })
end, { silent = true, desc = "Next diagnostic" })

-- Toggle diagnostics globally (<leader>ha) or per buffer (<leader>hq)
-- with statusline indicators.
local DIAG_OFF_MARKER = "\u{F0209} " -- Nerd Font nf-md-eye_off
local DIAG_GLOBAL_MARKER = "\u{F059F}" -- Nerd Font nf-md-web

function _G.lsp_diag_status()
	if not vim.diagnostic.is_enabled() then
		return DIAG_GLOBAL_MARKER .. DIAG_OFF_MARKER
	end
	local bufnr = vim.api.nvim_get_current_buf()
	if not vim.diagnostic.is_enabled({ bufnr = bufnr }) then
		return DIAG_OFF_MARKER
	end
	return ""
end

local function diag_toggle_global()
	local next_state = not vim.diagnostic.is_enabled()
	vim.diagnostic.enable(next_state)
	vim.notify("diagnostics (all buffers): " .. (next_state and "on" or "off"))
	vim.cmd("redrawstatus!")
end

local function diag_toggle_buffer()
	local bufnr = vim.api.nvim_get_current_buf()
	local next_state = not vim.diagnostic.is_enabled({ bufnr = bufnr })
	vim.diagnostic.enable(next_state, { bufnr = bufnr })
	vim.notify("diagnostics (this buffer): " .. (next_state and "on" or "off"))
	vim.cmd("redrawstatus!")
end

keyset({ "n", "x" }, "<leader>ha", diag_toggle_global, {
	silent = true,
	nowait = true,
	desc = "Toggle diagnostics (all buffers)",
})
keyset({ "n", "x" }, "<leader>hq", diag_toggle_buffer, {
	silent = true,
	nowait = true,
	desc = "Toggle diagnostics (current buffer)",
})

vim.opt.statusline:prepend("%{v:lua.lsp_diag_status()}")

-- ============================================================================
-- Hover & Yank Type Under Cursor (K and gK)
-- ============================================================================
function _G.show_docs()
	local cw = vim.fn.expand("<cword>")
	if vim.tbl_contains({ "vim", "help" }, vim.bo.filetype) then
		vim.cmd("h " .. cw)
	elseif #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" }) > 0 then
		vim.lsp.buf.hover({ border = "single" })
	else
		vim.cmd("!" .. vim.o.keywordprg .. " " .. cw)
	end
end
keyset("n", "K", _G.show_docs, { silent = true, desc = "Show documentation / hover" })

local function hover_code_block(lines)
	local out, inside, first_line = {}, false, nil
	for _, line in ipairs(lines) do
		if line:match("^%s*```") then
			if inside then
				return out
			end
			inside = true
		elseif inside then
			table.insert(out, line)
		elseif first_line == nil and line:match("%S") then
			first_line = line
		end
	end
	if #out > 0 then
		return out
	end
	if first_line then
		return { first_line }
	end
	return {}
end

local function top_level_colon(s)
	local depth = 0
	for i = 1, #s do
		local c = s:sub(i, i)
		if c:match("[%(%[{<]") then
			depth = depth + 1
		elseif c:match("[%)%]}>]") then
			depth = depth - 1
		elseif c == ":" and depth <= 0 then
			return i
		end
	end
	return nil
end

local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function extract_type(lines)
	if #lines == 0 then
		return nil
	end

	local head = trim(lines[1])
	-- Drop tsserver/pyright style qualifiers: "(variable) x: string"
	head = head:gsub("^%b()%s*", "")
	-- Drop a leading declaration keyword: "var x string", "let x: String".
	head = head:gsub("^[%w_]+%s+", function(kw)
		local word = kw:match("^[%w_]+")
		if
			word == "var"
			or word == "let"
			or word == "const"
			or word == "val"
			or word == "field"
			or word == "type"
		then
			return ""
		end
		return kw
	end)

	local colon = top_level_colon(head)
	local result
	if colon then
		result = trim(head:sub(colon + 1))
	else
		-- Go/gopls form: "x string", "s []byte"
		result = head:match("^[%w_%.]+%s+(.+)$")
	end
	if not result then
		return nil
	end

	if #lines > 1 then
		local rest = { result }
		for i = 2, #lines do
			table.insert(rest, lines[i])
		end
		result = table.concat(rest, "\n")
	end

	result = trim(result)
	if result == "" or result == "unknown" then
		return nil
	end
	return result
end

local function yank_type()
	local register = vim.v.register
	local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" })
	if #clients == 0 then
		vim.notify("Type yank: no LSP hover client", vim.log.levels.WARN)
		return
	end

	local client = clients[1]
	local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
	client:request("textDocument/hover", params, function(err, res)
		if err then
			vim.notify("Type yank: " .. tostring(err.message or err), vim.log.levels.WARN)
			return
		end
		if not res or not res.contents then
			vim.notify("Type yank: no hover information", vim.log.levels.WARN)
			return
		end
		local md_lines = vim.lsp.util.convert_input_to_markdown_lines(res.contents)
		local type_text = extract_type(hover_code_block(md_lines))
		if not type_text then
			vim.notify("Type yank: could not determine type", vim.log.levels.WARN)
			return
		end
		vim.fn.setreg(register, type_text, "c")
		if register == '"' then
			vim.fn.setreg("0", type_text, "c")
		end
		vim.notify("Yanked type: " .. type_text)
	end, 0)
end

keyset("n", "gK", yank_type, { silent = true, desc = "Yank type under cursor" })

-- ============================================================================
-- Symbol Rename in Normal Mode at Start of Symbol (<leader>rn)
-- ============================================================================
local function rename_symbol_normal_mode()
	local cur_word = vim.fn.expand("<cword>")
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buftype = "nofile"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { cur_word })

	local width = math.max(#cur_word + 12, 30)
	local origin_win = vim.api.nvim_get_current_win()
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = width,
		height = 1,
		style = "minimal",
		border = "single",
		title = " Rename ",
		title_pos = "left",
	})

	vim.api.nvim_win_set_cursor(win, { 1, 0 })

	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		if vim.api.nvim_win_is_valid(origin_win) then
			vim.api.nvim_set_current_win(origin_win)
		end
	end

	local function submit()
		local new_name = trim(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "")
		vim.cmd("stopinsert")
		close()
		if new_name ~= "" and new_name ~= cur_word then
			vim.lsp.buf.rename(new_name)
		end
	end

	keyset({ "n", "i" }, "<CR>", submit, { buffer = buf, silent = true, nowait = true })
	keyset("n", "<Esc>", close, { buffer = buf, silent = true, nowait = true })
	keyset("n", "q", close, { buffer = buf, silent = true, nowait = true })
	keyset({ "n", "i" }, "<C-c>", function()
		vim.cmd("stopinsert")
		close()
	end, { buffer = buf, silent = true, nowait = true })
end

-- ============================================================================
-- File Rename with LSP Workspace Edits (<leader>rf)
-- ============================================================================
local function rename_current_file()
	local bufnr = vim.api.nvim_get_current_buf()
	local old_name = vim.api.nvim_buf_get_name(bufnr)
	if old_name == "" then
		vim.notify("Cannot rename unnamed buffer", vim.log.levels.WARN)
		return
	end

	vim.ui.input({ prompt = "Rename file: ", default = old_name, completion = "file" }, function(new_name)
		if not new_name or new_name == "" or new_name == old_name then
			return
		end

		local old_uri = vim.uri_from_fname(old_name)
		local new_uri = vim.uri_from_fname(new_name)
		local params = { files = { { oldUri = old_uri, newUri = new_uri } } }

		-- Notify LSPs before renaming and apply workspace edits
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			if client:supports_method("workspace/willRenameFiles") then
				local resp = client:request_sync("workspace/willRenameFiles", params, 3000, bufnr)
				if resp and resp.result then
					vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
				end
			end
		end

		local parent = vim.fn.fnamemodify(new_name, ":h")
		if parent ~= "" then
			vim.fn.mkdir(parent, "p")
		end

		local ok, err = vim.uv.fs_rename(old_name, new_name)
		if not ok then
			vim.notify("Rename failed: " .. tostring(err), vim.log.levels.ERROR)
			return
		end

		vim.cmd("silent keepalt file " .. vim.fn.fnameescape(new_name))
		vim.cmd("silent write!")

		for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			if client:supports_method("workspace/didRenameFiles") then
				client:notify("workspace/didRenameFiles", params)
			end
		end

		vim.notify("Renamed to " .. new_name)
	end)
end

keyset("n", "<leader>rf", rename_current_file, { silent = true, desc = "Rename current file (LSP)" })

-- ============================================================================
-- Keybindings & Buffer-local LSP Attachment
-- ============================================================================
-- Clear Neovim's default gr* mappings so `gr` fires immediately without timeoutlen delay
for _, lhs in ipairs({ "grn", "gra", "grr", "gri", "grt" }) do
	pcall(vim.keymap.del, "n", lhs)
end
pcall(vim.keymap.del, "x", "gra")

local lsp_group = vim.api.nvim_create_augroup("TommyLsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_group,
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local bopts = { buffer = bufnr, silent = true }

		-- Navigation
		keyset("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", bopts, { desc = "Go to definition" }))
		keyset("n", "gy", vim.lsp.buf.type_definition, vim.tbl_extend("force", bopts, { desc = "Go to type definition" }))
		keyset("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", bopts, { desc = "Go to implementation" }))
		keyset("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", bopts, { desc = "Show references" }))

		-- Rename
		keyset("n", "<leader>rn", rename_symbol_normal_mode, vim.tbl_extend("force", bopts, { desc = "Rename symbol" }))

		-- Code actions & refactoring
		local action_opts = { buffer = bufnr, silent = true, nowait = true }
		keyset({ "n", "x" }, "<leader>a", vim.lsp.buf.code_action, vim.tbl_extend("force", action_opts, { desc = "Code action" }))
		keyset("n", "<leader>ac", vim.lsp.buf.code_action, vim.tbl_extend("force", action_opts, { desc = "Code action at cursor" }))
		keyset("n", "<leader>as", function()
			vim.lsp.buf.code_action({ context = { only = { "source" } } })
		end, vim.tbl_extend("force", action_opts, { desc = "Source code actions" }))
		keyset("n", "<leader>al", function()
			vim.lsp.buf.code_action({ apply = true, context = { only = { "quickfix" } } })
		end, vim.tbl_extend("force", action_opts, { desc = "Quickfix current line" }))
		keyset("n", "<leader>re", function()
			vim.lsp.buf.code_action({ context = { only = { "refactor" } } })
		end, vim.tbl_extend("force", bopts, { desc = "Refactor code action" }))
		keyset({ "n", "x" }, "<leader>r", function()
			vim.lsp.buf.code_action({ context = { only = { "refactor" } } })
		end, vim.tbl_extend("force", bopts, { desc = "Refactor selection" }))
		keyset("n", "<leader>cl", vim.lsp.codelens.run, vim.tbl_extend("force", action_opts, { desc = "Run CodeLens" }))

		-- Selection range (<C-s>)
		keyset({ "n", "x" }, "<C-s>", function()
			vim.lsp.buf.selection_range(1)
		end, vim.tbl_extend("force", bopts, { desc = "Expand LSP selection range" }))

		-- Inlay hints (default off, toggle with <leader>hi)
		keyset({ "n", "x" }, "<leader>hi", function()
			local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
			vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
		end, vim.tbl_extend("force", action_opts, { desc = "Toggle inlay hints" }))

		-- Call hierarchy
		keyset({ "n", "x" }, "<leader>ho", vim.lsp.buf.outgoing_calls, vim.tbl_extend("force", action_opts, { desc = "Outgoing calls" }))
		keyset({ "n", "x" }, "<leader>hc", vim.lsp.buf.incoming_calls, vim.tbl_extend("force", action_opts, { desc = "Incoming calls" }))

		-- Document highlight on CursorHold
		if client and client:supports_method("textDocument/documentHighlight") then
			local hl_group = vim.api.nvim_create_augroup("TommyLspHighlight_" .. bufnr, { clear = true })
			vim.api.nvim_create_autocmd("CursorHold", {
				group = hl_group,
				buffer = bufnr,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				group = hl_group,
				buffer = bufnr,
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})

-- Telescope replacements for CocList mappings
local telescope = require("telescope.builtin")
local list_opts = { silent = true, nowait = true }
keyset("n", "<leader>ca", telescope.diagnostics, vim.tbl_extend("force", list_opts, { desc = "Diagnostics list" }))
keyset("n", "<leader>cc", telescope.commands, vim.tbl_extend("force", list_opts, { desc = "Commands" }))
keyset("n", "<leader>co", telescope.lsp_document_symbols, vim.tbl_extend("force", list_opts, { desc = "Document symbols" }))
keyset("n", "<leader>cs", telescope.lsp_dynamic_workspace_symbols, vim.tbl_extend("force", list_opts, { desc = "Workspace symbols" }))
keyset("n", "<leader>cj", "<Cmd>cnext<CR>", vim.tbl_extend("force", list_opts, { desc = "Next quickfix item" }))
keyset("n", "<leader>ck", "<Cmd>cprev<CR>", vim.tbl_extend("force", list_opts, { desc = "Previous quickfix item" }))
keyset("n", "<leader>cp", telescope.resume, vim.tbl_extend("force", list_opts, { desc = "Resume last picker" }))

-- ============================================================================
-- Language Servers (Neovim 0.12 native vim.lsp.config + vim.lsp.enable)
-- ============================================================================
local schemastore = require("schemastore")

vim.lsp.config("*", {
	capabilities = blink.get_lsp_capabilities(),
})

vim.lsp.config("basedpyright", {
	settings = {
		basedpyright = {
			disableOrganizeImports = true,
			analysis = {
				diagnosticMode = "workspace",
				diagnosticSeverityOverrides = {
					reportCallInDefaultInitializer = "none",
					reportPrivateUsage = "none",
					reportUnusedImport = "none",
					reportUnusedVariable = "none",
					reportUnusedParameter = "none",
					reportUnknownMemberType = "none",
					reportUnusedCallResult = "none",
					reportUnreachable = "unreachable",
					reportUnusedClass = "unused",
					reportUnusedFunction = "unused",
					reportDeprecated = "deprecated",
					reportInvalidCast = "information",
					reportMissingModuleSource = "warning",
					reportMissingTypeStubs = "warning",
					reportPrivateLocalImportUsage = "warning",
					reportUnknownArgumentType = "warning",
					reportUnknownLambdaType = "warning",
					reportUnknownParameterType = "warning",
					reportUnknownVariableType = "warning",
				},
			},
		},
	},
})

vim.lsp.config("ts_ls", {
	settings = {
		completions = {
			completeFunctionCalls = true,
		},
		typescript = {
			inlayHints = {
				includeInlayEnumMemberValueHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayVariableTypeHints = true,
			},
		},
	},
})

vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			check = { command = "clippy" },
			imports = {
				granularity = { group = "module" },
				prefix = "self",
			},
		},
	},
})

vim.lsp.config("jsonls", {
	settings = {
		json = {
			schemas = schemastore.json.schemas(),
			validate = { enable = true },
		},
	},
})

vim.lsp.config("yamlls", {
	settings = {
		yaml = {
			schemaStore = {
				enable = false,
				url = "",
			},
			schemas = schemastore.yaml.schemas(),
		},
	},
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false },
		},
	},
})

vim.lsp.enable({
	"basedpyright",
	"bashls",
	"buf_ls",
	"dockerls",
	"eslint",
	"gopls",
	"jsonls",
	"lua_ls",
	"nixd",
	"ruff",
	"rust_analyzer",
	"taplo",
	"ts_ls",
	"yamlls",
})

-- ============================================================================
-- Formatting (conform.nvim) & User Commands (:Format, :OR)
-- ============================================================================
local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		lua = { "stylua" },
		nix = { "nixfmt" },
		proto = { "buf" },
		python = { "ruff_organize_imports", "ruff_format" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
	},
	format_on_save = function(bufnr)
		local ft = vim.bo[bufnr].filetype
		local enabled = {
			javascript = true,
			javascriptreact = true,
			lua = true,
			nix = true,
			proto = true,
			python = true,
			typescript = true,
			typescriptreact = true,
		}
		if enabled[ft] then
			return { timeout_ms = 2000, lsp_format = "fallback" }
		end
	end,
})

vim.api.nvim_create_user_command("Format", function()
	conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format current buffer" })

vim.api.nvim_create_user_command("OR", function()
	if vim.bo.filetype == "python" then
		conform.format({ formatters = { "ruff_organize_imports" }, async = true })
	else
		vim.lsp.buf.code_action({
			context = { only = { "source.organizeImports" } },
			apply = true,
		})
	end
end, { desc = "Organize imports" })

-- ============================================================================
-- Linting (nvim-lint: markdownlint-cli2 + cspell)
-- ============================================================================
local lint = require("lint")
local config_dir = vim.fn.stdpath("config")

lint.linters["markdownlint-cli2"].args = {
	"--config",
	config_dir .. "/markdownlint.jsonc",
	"-",
}

lint.linters.cspell.args = {
	"lint",
	"--config",
	config_dir .. "/cspell.json",
	"--no-color",
	"--no-progress",
	"--no-summary",
	function()
		return "stdin://" .. vim.api.nvim_buf_get_name(0)
	end,
}

local cspell_fts = {
	"asciidoc",
	"c",
	"cpp",
	"cs",
	"css",
	"gitcommit",
	"go",
	"handlebars",
	"haskell",
	"html",
	"java",
	"javascript",
	"javascriptreact",
	"json",
	"jsonc",
	"less",
	"markdown",
	"php",
	"proto",
	"python",
	"rst",
	"rust",
	"scala",
	"scss",
	"tex",
	"text",
	"typescript",
	"typescriptreact",
	"vim",
	"yaml",
}

lint.linters_by_ft = {
	markdown = { "markdownlint-cli2", "cspell" },
}
for _, ft in ipairs(cspell_fts) do
	if not lint.linters_by_ft[ft] then
		lint.linters_by_ft[ft] = { "cspell" }
	end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
	group = vim.api.nvim_create_augroup("TommyLint", { clear = true }),
	callback = function()
		if vim.bo.buftype == "" then
			lint.try_lint()
		end
	end,
})
