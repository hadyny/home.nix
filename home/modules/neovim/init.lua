local vim = vim
local border = "solid"

vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.smartindent = true
vim.o.shiftwidth = 4
vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.hlsearch = false
vim.o.winborder = border
vim.o.laststatus = 3
vim.o.statusline = " %f %m %= %l:%c ✽ [%{mode()}] "
vim.o.relativenumber = true
vim.o.scrolloff = 4
vim.o.sidescrolloff = 8

vim.diagnostic.config({
	virtual_text = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅙",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "󰋼",
			[vim.diagnostic.severity.HINT] = "󰌵",
		},
	},
	underline = true,
})

if vim.g.vscode then
	return
end

require("mini.bufremove").setup()
local MiniIcons = require("mini.icons")
MiniIcons.setup()
MiniIcons.mock_nvim_web_devicons()

require("rose-pine").setup({
    variant = "auto",
	dark_variant = "moon",
	highlight_groups = {
		StatusLine = { fg = "iris", bg = "iris", blend = 10 },
		StatusLineNC = { fg = "subtle", bg = "surface" },
	},
})
vim.cmd("colorscheme rose-pine-moon")

require("nvim-highlight-colors").setup({
	enable_tailwind = true,
	render = "foreground",
})

require("blink.cmp").setup({
	completion = {
		list = { selection = { preselect = false, auto_insert = true } },
		menu = {
			scrolloff = 2,
			scrollbar = false,
			draw = {
				columns = { { "kind_icon" }, { "label", gap = 1 } },
				components = {
					-- customize the drawing of kind icons
					kind_icon = {
						text = function(ctx)
							-- default kind icon
							local icon = ctx.kind_icon
							-- if LSP source, check for color derived from documentation
							if ctx.item.source_name == "LSP" then
								local color_item =
									require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
								if color_item and color_item.abbr then
									icon = color_item.abbr
								end
							end
							return icon .. ctx.icon_gap
						end,
						highlight = function(ctx)
							-- default highlight group
							local highlight = "BlinkCmpKind" .. ctx.kind
							-- if LSP source, check for color derived from documentation
							if ctx.item.source_name == "LSP" then
								local color_item =
									require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
								if color_item and color_item.abbr_hl_group then
									highlight = color_item.abbr_hl_group
								end
							end
							return highlight
						end,
					},
					label = {
						text = function(ctx)
							return require("colorful-menu").blink_components_text(ctx)
						end,
						highlight = function(ctx)
							return require("colorful-menu").blink_components_highlight(ctx)
						end,
					},
				},
			},
		},
		documentation = { auto_show = true, auto_show_delay_ms = 250 },
	},
	keymap = {
		preset = "default",
		["<CR>"] = { "select_and_accept", "fallback" },
	},
})

local wk = require("which-key")
wk.setup({ preset = "helix" })
wk.add({
	{ "<leader>f", group = "file" },
	{ "<leader>c", group = "code" },
	{ "<leader>g", group = "git" },
	{ "<leader>s", group = "search" },
	{ "<leader>u", group = "ui" },
	{ "g", group = "goto" },
	{ "<leader>r", group = "run" },
	{ "<leader>w", proxy = "<c-w>", group = "windows" },
	{
		"<leader>b",
		group = "buffers",
		expand = function()
			return require("which-key.extras").expand.buf()
		end,
	},
})

require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
})

require("gitsigns").setup()

local fzf = require("fzf-lua")
fzf.setup({ "ivy","borderless-full", code_actions = { previewer = "codeaction_native" }})
fzf.register_ui_select()

local capabilities = require("blink.cmp").get_lsp_capabilities()
local lspconfig = require("lspconfig")
lspconfig.eslint.setup({
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
})
lspconfig.tailwindcss.setup({ capabilities = capabilities })
lspconfig.graphql.setup({ capabilities = capabilities })
lspconfig.lua_ls.setup({ capabilities = capabilities })
lspconfig.nil_ls.setup({ capabilities = capabilities })

local null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.completion.spell,
		null_ls.builtins.code_actions.gitsigns,
		null_ls.builtins.code_actions.refactoring,
		null_ls.builtins.diagnostics.terraform_validate,
		null_ls.builtins.formatting.csharpier,
		null_ls.builtins.formatting.nixfmt,
		null_ls.builtins.formatting.rustywind,
		null_ls.builtins.formatting.terraform_fmt,
	},
})

require("typescript-tools").setup({})
require("tailwind-tools").setup({
	document_color = { enabled = false },
	conceal = {
		enabled = true,
		min_length = 10,
	},
})
require("tsc").setup()

require("CopilotChat").setup({})

require("neotest").setup({
	adapters = {
		require("neotest-vitest"),
		require("neotest-dotnet")({
			dap = { justMyCode = false },
		}),
	},
})

require("tiny-inline-diagnostic").setup({
	multilines = true,
	break_line = { enabled = true },
})

require("roslyn").setup({
	exe = "Microsoft.CodeAnalysis.LanguageServer",
})

require("easy-dotnet").setup({
	test_runner = {
		viewmode = "float",
		mappings = {
			run_test_from_buffer = { lhs = "<leader>r", desc = "run test from buffer" },
			filter_failed_tests = { lhs = "<leader>fe", desc = "filter failed tests" },
			debug_test = { lhs = "<leader>dd", desc = "debug test" },
			go_to_file = { lhs = "g", desc = "got to file" },
			run_all = { lhs = "<leader>R", desc = "run all tests" },
			run = { lhs = "<leader>rt", desc = "run test" },
			peek_stacktrace = { lhs = "<leader>p", desc = "peek stacktrace of failed test" },
			expand = { lhs = "o", desc = "expand" },
			expand_node = { lhs = "E", desc = "expand node" },
			expand_all = { lhs = "-", desc = "expand all" },
			collapse_all = { lhs = "W", desc = "collapse all" },
			close = { lhs = "q", desc = "close testrunner" },
			refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" },
		},
	},
})

-- configure dap
local dap = require("dap")

-- .NET (C#) configuration
-- easy-dotnet setup
local dotnet = require("easy-dotnet")
local debug_dll = nil

local function ensure_dll()
	if debug_dll ~= nil then
		return debug_dll
	end
	local dll = dotnet.get_debug_dll()
	debug_dll = dll
	return dll
end
local function rebuild_project(co, path)
	local spinner = require("easy-dotnet.ui-modules.spinner").new()
	spinner:start_spinner("Building")
	vim.fn.jobstart(string.format("dotnet build %s", path), {
		on_exit = function(_, return_code)
			if return_code == 0 then
				spinner:stop_spinner("Built successfully")
			else
				spinner:stop_spinner("Build failed with exit code " .. return_code, vim.log.levels.ERROR)
				error("Build failed")
			end
			coroutine.resume(co)
		end,
	})
	coroutine.yield()
end

dap.listeners.before["event_terminated"]["easy-dotnet"] = function()
	debug_dll = nil
end
-- end easy-dotnet setup

dap.adapters.coreclr = {
	type = "executable",
	command = "netcoredbg",
	args = { "--interpreter=vscode" },
}
dap.configurations.cs = {
	{
		type = "coreclr",
		name = "Launch .NET",
		request = "launch",
		env = function()
			local dll = ensure_dll()
			local vars = dotnet.get_environment_variables(dll.project_name, dll.relative_project_path)
			return vars or nil
		end,
		program = function()
			local dll = ensure_dll()
			local co = coroutine.running()
			rebuild_project(co, dll.project_path)
			return dll.relative_dll_path
		end,
		cwd = function()
			local dll = ensure_dll()
			return dll.relative_project_path
		end,
	},
}
-- TypeScript configuration
dap.configurations.typescript = {
	{
		type = "node2",
		name = "Launch TypeScript",
		request = "launch",
		program = "${file}",
		cwd = vim.fn.getcwd(),
		sourceMaps = true,
		protocol = "inspector",
		outFiles = { "${workspaceFolder}/dist/**/*.js" },
	},
}
dap.configurations.javascript = dap.configurations.typescript

-- Mappings
vim.g.mapleader = " "
local map = vim.keymap.set

-- DAP mappings
map("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", { desc = "Start/Continue Debugging" })
map("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", { desc = "Step Over" })
map("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", { desc = "Step Into" })
map("n", "<F12>", "<Cmd>lua require'dap'.step_out()<CR>", { desc = "Step Out" })
map("n", "<Leader>db", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Toggle Breakpoint" })
map("n", "<Leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>", { desc = "Open REPL" })

-- DAP UI widgets
map("n", "<Leader>dk", "<Cmd>lua require'dap.ui.widgets'.hover()<CR>", { desc = "DAP Hover Widget" })
map(
	"n",
	"<Leader>ds",
	"<Cmd>lua require'dap.ui.widgets'.sidebar(require'dap.ui.widgets'.scopes).open()<CR>",
	{ desc = "DAP Scopes" }
)
map(
	"n",
	"<Leader>df",
	"<Cmd>lua require'dap.ui.widgets'.sidebar(require'dap.ui.widgets'.frames).open()<CR>",
	{ desc = "DAP Frames" }
)
map(
	"n",
	"<Leader>dV",
	"<Cmd>lua require'dap.ui.widgets'.hover(function() return vim.fn.expand('<cexpr>') end)<CR>",
	{ desc = "DAP Hover Expression" }
)
map(
	"v",
	"<Leader>dv",
	"<Cmd>lua require'dap.ui.widgets'.hover(function() return vim.fn.expand('<cexpr>') end)<CR>",
	{ desc = "DAP Hover Selection" }
)
map(
	"n",
	"<Leader>dc",
	"<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
	{ desc = "Conditional Breakpoint" }
)
map(
	"n",
	"<Leader>dm",
	"<Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
	{ desc = "Logpoint Message" }
)

-- easy-dotnet mappings
map("n", "<Leader>db", "<Cmd>lua require('easy-dotnet').build_solution()<cr>", { desc = "Build .NET solution" })
map("n", "<Leader>dr", "<Cmd>lua require('easy-dotnet').run()<cr>", { desc = "Run .NET project" })
map("n", "<Leader>dt", "<Cmd>lua require('easy-dotnet').test()<cr>", { desc = "Run tests" })
map("n", "<Leader>dp", "<Cmd>lua require('easy-dotnet').testrunner()<cr>", { desc = "Test runner" })
map("n", "<Leader>da", "<Cmd>lua require('easy-dotnet').project_view()<cr>", { desc = "Manage Projects" })

-- neotest mappings
map("n", "<Leader>tn", "<Cmd>lua require('neotest').run.run()<CR>", { desc = "Run nearest test" })
map("n", "<Leader>tf", "<Cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", { desc = "Run test file" })
map("n", "<Leader>tl", "<Cmd>lua require('neotest').run.run_last()<CR>", { desc = "Run last test" })
map("n", "<Leader>td", "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", { desc = "Debug nearest test" })
map("n", "<Leader>ts", "<Cmd>lua require('neotest').summary.toggle()<CR>", { desc = "Toggle test summary" })
map("n", "<Leader>to", "<Cmd>lua require('neotest').output.open()<CR>", { desc = "Show test output" })
map("n", "<Leader>tp", "<Cmd>lua require('neotest').output_panel.toggle()<CR>", { desc = "Toggle output panel" })
map(
	"n",
	"[t",
	"<Cmd>lua require('neotest').jump.prev({ status = 'failed' })<CR>",
	{ desc = "Jump to previous failed test" }
)
map(
	"n",
	"]t",
	"<Cmd>lua require('neotest').jump.next({ status = 'failed' })<CR>",
	{ desc = "Jump to next failed test" }
)

-- general mappings
map("n", "<Leader>e", "<Cmd>Yazi<cr>", { desc = "Explorer" })
map("n", "<Leader>cr", "<Cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
map("n", "<Leader>cf", "<Cmd>lua vim.lsp.buf.format()<cr>", { desc = "Format buffer" })
map("n", "<Leader>ca", "<Cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Code actions" })
map("n", "<Leader>cc", "<Cmd>CopilotChat<cr>", { desc = "Copilot chat" })

-- Smart mappings
map("n", "<leader><space>", "<Cmd>lua require('fzf-lua').files()<cr>", { desc = "Find Files" })
map("n", "<leader>,", "<Cmd>lua require('fzf-lua').buffers()<cr>", { desc = "Buffers" })
map("n", "<leader>/", "<Cmd>lua require('fzf-lua').blines()<cr>", { desc = "Buffer Lines" })
map("n", "<leader>:", "<Cmd>lua require('fzf-lua').command_history()<cr>", { desc = "Command History" })

-- Buffer mappings
map("n", "<Leader>bd", "<Cmd>lua MiniBufremove.delete()<cr>", { desc = "Delete" })

-- Find mappings
map("n", "<leader>fr", "<Cmd>lua require('fzf-lua').oldfiles()<cr>", { desc = "Recent" })

-- Git mappings
map("n", "<leader>gb", "<Cmd>lua require('fzf-lua').git_branches()<cr>", { desc = "Git Branches" })
map("n", "<leader>gs", "<Cmd>lua require('fzf-lua').git_status()<cr>", { desc = "Git Status" })
map("n", "<leader>gS", "<Cmd>lua require('fzf-lua').git_stash()<cr>", { desc = "Git Stash" })
map("n", "<leader>gp", "<Cmd>lua require('fzf-lua').git_commits()<cr>", { desc = "Project Commits" })
map("n", "<leader>gc", "<Cmd>lua require('fzf-lua').git_bcommits()<cr>", { desc = "Buffer Commits" })
map("n", "<leader>gB", "<Cmd>lua require('fzf-lua').git_blame()<cr>", { desc = "Git Blame" })

-- Grep mappings
map("n", "<leader>sg", "<Cmd>lua require('fzf-lua').live_grep_native()<cr>", { desc = "Grep project" })

-- Search mappings
map("n", '<leader>s"', "<Cmd>lua require('fzf-lua').registers()<cr>", { desc = "Registers" })
map("n", "<leader>s/", "<Cmd>lua require('fzf-lua').search_history()<cr>", { desc = "Search History" })
map("n", "<leader>sa", "<Cmd>lua require('fzf-lua').autocmds()<cr>", { desc = "Autocmds" })
map("n", "<leader>sc", "<Cmd>lua require('fzf-lua').command_history()<cr>", { desc = "Command History" })
map("n", "<leader>sC", "<Cmd>lua require('fzf-lua').commands()<cr>", { desc = "Commands" })
map("n", "<leader>sd", "<Cmd>lua require('fzf-lua').diagnostics_workspace()<cr>", { desc = "Diagnostics" })
map("n", "<leader>sD", "<Cmd>lua require('fzf-lua').diagnostics_document()<cr>", { desc = "Buffer Diagnostics" })
map("n", "<leader>sH", "<Cmd>lua require('fzf-lua').highlights()<cr>", { desc = "Highlights" })
map("n", "<leader>sj", "<Cmd>lua require('fzf-lua').jumps()<cr>", { desc = "Jumps" })
map("n", "<leader>sk", "<Cmd>lua require('fzf-lua').keymaps()<cr>", { desc = "Keymaps" })
map("n", "<leader>sl", "<Cmd>lua require('fzf-lua').grep_loclist()<cr>", { desc = "Location List" })
map("n", "<leader>sm", "<Cmd>lua require('fzf-lua').marks()<cr>", { desc = "Marks" })
map("n", "<leader>sM", "<Cmd>lua require('fzf-lua').manpages()<cr>", { desc = "Man Pages" })
map("n", "<leader>sq", "<Cmd>lua require('fzf-lua').grep_quickfix()<cr>", { desc = "Quickfix List" })
map("n", "<leader>uC", "<Cmd>lua require('fzf-lua').colorschemes()<cr>", { desc = "Colorschemes" })

-- LSP mappings
map("n", "gd", "<Cmd>lua require('fzf-lua').lsp_definitions()<cr>", { desc = "Goto Definition" })
map("n", "gD", "<Cmd>lua require('fzf-lua').lsp_declarations()<cr>", { desc = "Goto Declaration" })
map("n", "gr", "<Cmd>lua require('fzf-lua').lsp_references()<cr>", { desc = "References", nowait = true })
map("n", "gI", "<Cmd>lua require('fzf-lua').lsp_implementations()<cr>", { desc = "Goto Implementation" })
map("n", "<leader>ss", "<Cmd>lua require('fzf-lua').lsp_document_symbols()<cr>", { desc = "LSP Symbols" })
map("n", "<leader>sS", "<Cmd>lua require('fzf-lua').lsp_workspace_symbols()<cr>", { desc = "LSP Workspace Symbols" })
map("n", "<leader>z", "<Cmd>lua require('fzf-lua').zoxide()<cr>", { desc = "Zoxide projects" })
