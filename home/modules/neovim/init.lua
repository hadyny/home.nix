local vim = vim
local options = vim.o
local globals = vim.g
local diagnostics = vim.diagnostic

globals.mapleader = " "
globals.maplocalleader = " "

options.termguicolors = true
options.cursorline = true
options.tabstop = 4
options.expandtab = true
options.breakindent = true
options.softtabstop = 4
options.smartindent = true
options.shiftwidth = 4
options.smartcase = true
options.ignorecase = true
options.laststatus = 3
options.statusline = " %f %m %= %l:%c ✽ [%{mode()}] "
options.number = true
options.relativenumber = true
options.scrolloff = 4
options.sidescrolloff = 8
options.completeopt = "menu,preview,noselect"
options.confirm = true
options.showmode = false
options.mouse = "a"
options.winborder = "single"
options.inccommand = "split"

vim.schedule(function()
	options.clipboard = "unnamedplus"
end)
options.foldlevel = 99
options.foldmethod = "expr"
options.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "User: Set LSP folding if client supports it",
	callback = function(ctx)
		local client = assert(vim.lsp.get_client_by_id(ctx.data.client_id))
		if client:supports_method("textDocument/foldingRange") then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		end
	end,
})

local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

diagnostics.config({
	virtual_text = false,
	signs = {
		text = {
			[diagnostics.severity.ERROR] = "󰅙",
			[diagnostics.severity.WARN] = "",
			[diagnostics.severity.INFO] = "󰋼",
			[diagnostics.severity.HINT] = "󰌵",
		},
	},
	underline = true,
})

local MiniIcons = require("mini.icons")
MiniIcons.setup()
MiniIcons.mock_nvim_web_devicons()
MiniIcons.tweak_lsp_kind()

require("mini.pick").setup()
require("mini.extra").setup()

require("catppuccin").setup({
	flavour = "auto",
	background = {
		light = "latte",
		dark = "mocha",
	},
	dim_inactive = { enabled = true },
	integrations = {
		diffview = true,
		gitgraph = true,
		mini = {
			enabled = true,
			indentscope_color = "lavender",
		},
	},
})
vim.cmd("colorscheme catppuccin-mocha")

require("nvim-highlight-colors").setup({
	enable_tailwind = true,
	render = "background",
})

local MiniCompletion = require("mini.completion")

local process_items = function(items, base)
	-- Don't show 'Text' suggestions
	items = vim.tbl_filter(function(x)
		return x.kind ~= 1
	end, items)
	return MiniCompletion.default_process_items(items, base)
end
local on_attach = function(args)
	vim.bo[args.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
end
vim.api.nvim_create_autocmd("LspAttach", { callback = on_attach })

MiniCompletion.setup({
	mappings = {
		go_in = "<RET>",
	},
	lsp_completion = { source_func = "omnifunc", auto_setup = false, process_items = process_items },
})

local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		-- Leader triggers
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },

		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },

		-- `g` key
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },

		-- Marks
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },

		-- Registers
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },

		-- Window commands
		{ mode = "n", keys = "<C-w>" },

		-- `z` key
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },
	},

	clues = {
		{ mode = "n", keys = "<Leader>f", desc = "files" },
		{ mode = "n", keys = "<Leader>c", desc = "code" },
		{ mode = "n", keys = "<Leader>g", desc = "git" },
		{ mode = "n", keys = "<Leader>s", desc = "search" },
		{ mode = "n", keys = "g", desc = "goto" },
		{ mode = "n", keys = "<Leader>t", desc = "typescript" },
		{ mode = "n", keys = "<Leader>d", desc = "dotnet" },
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
	},
})

require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
})

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		csharp = { "csharpier" },
		nix = { "nixfmt" },
	},
	default_format_opts = {
		lsp_format = "fallback",
	},
	format_on_save = { timeout_ms = 500 },
})
options.formatexpr = "v:lua.require'conform'.formatexpr()"

require("gitsigns").setup()

require("Snacks").setup({
	animate = { enabled = true },
	dim = { enabled = true },
	image = { enabled = true },
	notifier = { enabled = true },
	rename = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	picker = { enabled = false },
	words = { enabled = true },
})

local capabilities = MiniCompletion.get_lsp_capabilities()
local util = require("lspconfig.util")

local front_end_ft = {
	"javascript",
	"javascriptreact",
	"javascript.jsx",
	"typescript",
	"typescriptreact",
	"typescript.tsx",
	"graphql",
}

vim.lsp.config("eslint", { capabilities = capabilities, filetypes = front_end_ft })
vim.lsp.enable("eslint")

vim.lsp.config("tailwindcss", { capabilities = capabilities })
vim.lsp.enable("tailwindcss")

vim.lsp.config("graphql", { capabilities = capabilities, root_dir = util.root_pattern(".git") })
vim.lsp.enable("graphql")

vim.lsp.config("lua_ls", { capabilities = capabilities })
vim.lsp.enable("lua_ls")

vim.lsp.config("nil_ls", { capabilities = capabilities })
vim.lsp.enable("nil_ls")

require("typescript-tools").setup({})
require("tailwind-tools").setup({
	document_color = { enabled = false },
	conceal = {
		enabled = true,
		min_length = 10,
	},
})

require("CopilotChat").setup({})

require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
})

require("neotest").setup({
	adapters = {
		require("neotest-vitest"),
		require("neotest-dotnet")({
			dap = { justMyCode = false },
		}),
	},
})

local timer = vim.uv.new_timer()
local delay = 500
vim.api.nvim_create_autocmd({ "CursorMoved", "DiagnosticChanged" }, {
	callback = function()
		if vim.fn.mode() == "n" then
			-- debounce
			timer:start(delay, 0, function()
				timer:stop()
				vim.schedule(function()
					vim.diagnostic.open_float(nil, { focusable = false, source = "if_many" })
					local _, win = vim.diagnostic.open_float(nil, { focusable = false, source = "if_many" })

					if not win then
						return
					end

					local cfg = vim.api.nvim_win_get_config(win)

					cfg.anchor = "NE"
					cfg.row = 0
					cfg.col = vim.o.columns - 1
					cfg.width = math.min(cfg.width or 999, math.floor(vim.o.columns * 0.6))
					cfg.height = math.min(cfg.height or 999, math.floor(vim.o.lines * 0.4))

					vim.api.nvim_win_set_config(win, cfg)
				end)
			end)
		end
	end,
})

require("tiny-code-action").setup({
	backend = "delta",
	picker = "snacks",
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
local map = vim.keymap.set

map("n", "gb", ":ls<cr>:b<space>", { noremap = true, desc = "Goto buffer" })

map("n", "<Esc>", ":noh<CR><Esc>", { noremap = true, silent = true }) -- escape to cancel search

map("n", "<leader><leader>", "<Cmd>Resume search<cr>", { desc = "Resume search" })
map("n", "<leader>/", "<Cmd>Pick buf_lines<cr>", { desc = "Buffer Lines" })
map("n", "<leader>:", "<Cmd>Pick history<cr>", { desc = "Command History" })
map(
	"n",
	"<Leader>e",
	"<Cmd>lua Snacks.explorer({ layout = { layout = { position = 'right' } } })<cr>",
	{ desc = "Explorer" }
)
map("n", "<Leader>E", "<Cmd>lua Snacks.explorer.reveal()<cr>", { desc = "Explorer file" })

-- LSP mappings
map("n", "<leader>sd", "<Cmd>Pick lsp scope='definition'<cr>", { desc = "Search definitions" })
map("n", "<leader>sr", "<Cmd>Pick lsp scope='references'<cr>", { desc = "Search References" })
map("n", "<leader>si", "<Cmd>Pick lsp scope='implementation'<cr>", { desc = "Search Implementations" })
map("n", "<leader>ss", "<Cmd>Pick lsp scope='document_symbol'<cr>", { desc = "LSP Symbols" })
map(
	"n",
	"<leader>sS",
	"<Cmd>Pick lsp scope='workspace_symbol' symbol_query=vim.fn.input('Symbol:\\ ')<cr>",
	{ desc = "LSP Workspace Symbols" }
)

-- file
map("n", "<leader>ff", "<Cmd>Pick files<cr>", { desc = "Find Files" })
map("n", "<leader>fr", "<Cmd>Pick oldfiles<cr>", { desc = "Recent" })
map("n", "<leader>f+", "<Cmd>set foldlevel=99<cr>", { desc = "Expand all folds" })
map("n", "<leader>f-", "<Cmd>set foldlevel=0<cr>", { desc = "Collapse all folds" })

map("n", "<leader>-", "<Cmd>foldclose<cr>", { desc = "Collapse current fold" })
map("n", "<leader>+", "<Cmd>foldopen<cr>", { desc = "Expand current fold" })

-- Buffer mappings
map("n", "<Leader>bd", "<Cmd>bdelete<cr>", { desc = "Delete" })
map("n", "<leader>bb", "<Cmd>Pick buffers<cr>", { desc = "Switch Buffers" })

-- code
map("n", "<Leader>cr", "<Cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
map("n", "<Leader>cf", "<Cmd>lua vim.lsp.buf.format()<cr>", { desc = "Format buffer" })
map("n", "<Leader>ca", "<Cmd>lua require('tiny-code-action').code_action()<cr>", { desc = "Code actions" })
map("n", "<Leader>cc", "<Cmd>CopilotChat<cr>", { desc = "Copilot chat" })

-- git
map("n", "<leader>gb", "<Cmd>Git blame<cr>", { desc = "Git Blame" })
map("n", "<leader>gB", "<Cmd>Pick git_branches<cr>", { desc = "Git Branches" })
map("n", "<leader>gs", "<Cmd>Pick git_commits<cr>", { desc = "Git Commits" })
map("n", "<leader>gS", "<Cmd>Pick git_files<cr>", { desc = "Git Files" })

-- search
map("n", "<leader>sg", "<Cmd>Pick grep_live<cr>", { desc = "Grep project" })
map("n", '<leader>s"', "<Cmd>Pick registers<cr>", { desc = "Registers" })
map("n", "<leader>sC", "<Cmd>Pick commands<cr>", { desc = "Commands" })
map("n", "<leader>sD", "<Cmd>Pick diagnostic<cr>", { desc = "Buffer Diagnostics" })
map("n", "<leader>sj", "<Cmd>Pick list scope='jump'<cr>", { desc = "Jumplist" })
map("n", "<leader>sk", "<Cmd>Pick keymaps<cr>", { desc = "Keymaps" })
map("n", "<leader>sm", "<Cmd>Pick marks<cr>", { desc = "Marks" })
map("n", "<leader>sq", "<Cmd>Pick list scope='quickfix'<cr>", { desc = "Quickfix List" })

-- typescript
map("n", "<Leader>tn", "<Cmd>lua require('neotest').run.run()<CR>", { desc = "Run nearest test" })
map("n", "<Leader>tf", "<Cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", { desc = "Run test file" })
map("n", "<Leader>tl", "<Cmd>lua require('neotest').run.run_last()<CR>", { desc = "Run last test" })
map("n", "<Leader>td", "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", { desc = "Debug nearest test" })
map("n", "<Leader>ts", "<Cmd>lua require('neotest').summary.toggle()<CR>", { desc = "Toggle test summary" })
map("n", "<Leader>to", "<Cmd>lua require('neotest').output.open()<CR>", { desc = "Show test output" })
map("n", "<Leader>tp", "<Cmd>lua require('neotest').output_panel.toggle()<CR>", { desc = "Toggle output panel" })
map("n", "<Leader>tt", "<Cmd>TailwindConcealToggle<cr>", { desc = "Toggle Tailwind concealing" })

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

-- dotnet
map("n", "<Leader>db", "<Cmd>lua require('easy-dotnet').build_solution()<cr>", { desc = "Build .NET solution" })
map("n", "<Leader>dr", "<Cmd>lua require('easy-dotnet').run()<cr>", { desc = "Run .NET project" })
map("n", "<Leader>dt", "<Cmd>lua require('easy-dotnet').test()<cr>", { desc = "Run tests" })
map("n", "<Leader>dp", "<Cmd>lua require('easy-dotnet').testrunner()<cr>", { desc = "Test runner" })
map("n", "<Leader>da", "<Cmd>lua require('easy-dotnet').project_view()<cr>", { desc = "Manage Projects" })

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
