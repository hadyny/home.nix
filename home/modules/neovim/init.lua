local vim = vim
local options = vim.o

options.termguicolors = true
options.cursorline = true
options.tabstop = 4
options.expandtab = true
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
options.completeopt = "menu,menuone,noselect"
options.confirm = true
options.showmode = false
options.mouse = "a"
options.winborder = "single"

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

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

local MiniIcons = require("mini.icons")
MiniIcons.setup()
MiniIcons.mock_nvim_web_devicons()
MiniIcons.tweak_lsp_kind()

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
		which_key = true,
		mini = {
			enabled = true,
			indentscope_color = "lavender",
		},
		telescope = {
			enabled = true,
		},
	},
})
vim.cmd("colorscheme catppuccin-mocha")

require("nvim-highlight-colors").setup({
	enable_tailwind = true,
	render = "background",
})

require("blink.cmp").setup({
	cmdline = {
		keymap = {
			preset = "cmdline",
			["<CR>"] = { "select_and_accept", "fallback" },
		},
	},
	completion = {
		list = { selection = { preselect = false, auto_insert = true } },
		menu = {
			border = "single",
			winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
			scrolloff = 2,
			scrollbar = false,
		},
		documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "single" } },
		ghost_text = { enabled = true },
	},
	keymap = {
		preset = "default",
		["<CR>"] = { "select_and_accept", "fallback" },
	},
	signature = { enabled = true },
})

local wk = require("which-key")
wk.setup({ preset = "classic" })
wk.add({
	{ "<leader>f", group = "file" },
	{ "<leader>c", group = "code" },
	{ "<leader>g", group = "git" },
	{ "<leader>s", group = "search" },
	{ "<leader>u", group = "ui" },
	{ "g", group = "goto" },
	{ "<leader>t", group = "typescript" },
	{ "<leader>d", group = "dotnet" },
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
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

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

require("actions-preview").setup({
	telescope = vim.tbl_extend("force", require("telescope.themes").get_dropdown({ border = false }), {
		make_value = nil,
		make_make_display = nil,
	}),
})

require("telescope").setup({
	defaults = {
		border = false,
		windblend = 10,
		layout_strategy = "horizontal",
		layout_config = {
			horizontal = {
				prompt_position = "top",
			},
		},
		sorting_strategy = "ascending",
	},
})
pcall(require("telescope").load_extension, "fzf")
pcall(require("telescope").load_extension, "frecency")

local capabilities = require("blink.cmp").get_lsp_capabilities()
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")

lspconfig.eslint.setup({
	capabilities = capabilities,
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"graphql",
	},
	on_attach = function(client, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
})
lspconfig.tailwindcss.setup({ capabilities = capabilities })
lspconfig.graphql.setup({
	capabilities = capabilities,
	root_dir = util.root_pattern(".git"),
})
lspconfig.lua_ls.setup({ capabilities = capabilities })
lspconfig.nil_ls.setup({ capabilities = capabilities })

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

require("tiny-inline-diagnostic").setup({
	multilines = true,
	break_line = { enabled = true },
	enable_on_insert = false,
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

map("n", "<Esc>", ":noh<CR><Esc>", { noremap = true, silent = true }) -- escape to cancel search

map("n", "<leader><leader>", "<Cmd>Telescope frecency<cr>", { desc = "Smart find files" })
map(
	"n",
	"<leader>/",
	"<Cmd>lua require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_ivy({ border = false }))<cr>",
	{ desc = "Buffer Lines" }
)
map("n", "<leader>:", "<Cmd>Telescope command_history<cr>", { desc = "Command History" })
map(
	"n",
	"<Leader>e",
	"<Cmd>lua Snacks.explorer({ layout = { layout = { position = 'right' } } })<cr>",
	{ desc = "Explorer" }
)
map("n", "<Leader>E", "<Cmd>lua Snacks.explorer.reveal()<cr>", { desc = "Explorer file" })

-- LSP mappings
map(
	"n",
	"gd",
	"<Cmd>lua require('telescope.builtin').lsp_definitions(require('telescope.themes').get_dropdown({ border = false }))<cr>",
	{ desc = "Goto Definition" }
)
map(
	"n",
	"gD",
	"<Cmd>lua require('telescope.builtin').lsp_declarations(require('telescope.themes').get_dropdown({ border = false }))<cr>",
	{ desc = "Goto Declaration" }
)
map(
	"n",
	"gr",
	"<Cmd>lua require('telescope.builtin').lsp_references(require('telescope.themes').get_dropdown({ border = false }))<cr>",
	{ desc = "References", nowait = true }
)
map(
	"n",
	"gI",
	"<Cmd>lua require('telescope.builtin').lsp_implementations(require('telescope.themes').get_dropdown({ border = false }))<cr>",
	{ desc = "Goto Implementation" }
)
map(
	"n",
	"<leader>ss",
	"<Cmd>lua require('telescope.builtin').lsp_document_symbols(require('telescope.themes').get_dropdown({ border = false }))<cr>",
	{ desc = "LSP Symbols" }
)
map(
	"n",
	"<leader>sS",
	"<Cmd>lua require('telescope.builtin').lsp_workspace_symbols(require('telescope.themes').get_dropdown({ border = false }))<cr>",
	{ desc = "LSP Workspace Symbols" }
)

-- file
map("n", "<leader>ff", "<Cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "<leader>fr", "<Cmd>Telescope oldfiles<cr>", { desc = "Recent" })

-- Buffer mappings
map("n", "<Leader>bd", "<Cmd>lua Snacks.bufdelete()<cr>", { desc = "Delete" })
map("n", "<leader>bb", "<Cmd>Telescope buffers<cr>", { desc = "Switch Buffers" })

-- code
map("n", "<Leader>cr", "<Cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
map("n", "<Leader>cf", "<Cmd>lua vim.lsp.buf.format()<cr>", { desc = "Format buffer" })
map("n", "<Leader>ca", "<Cmd>lua require('actions-preview').code_actions()<cr>", { desc = "Code actions" })
map("n", "<Leader>cc", "<Cmd>CopilotChat<cr>", { desc = "Copilot chat" })

-- git
map("n", "<leader>gb", "<Cmd>Git blame<cr>", { desc = "Git Blame" })
map("n", "<leader>gB", "<Cmd>Telescope git_branches<cr>", { desc = "Git Branches" })
map("n", "<leader>gs", "<Cmd>Telescope git_status<cr>", { desc = "Git Status" })
map("n", "<leader>gS", "<Cmd>Telescope git_stash<cr>", { desc = "Git Stash" })

-- search
map("n", "<leader>sw", "<Cmd>Telescope grep_string<cr>", { desc = "Current word" })
map("n", "<leader>sg", "<Cmd>Telescope live_grep<cr>", { desc = "Grep project" })
map("n", '<leader>s"', "<Cmd>Telescope registers<cr>", { desc = "Registers" })
map("n", "<leader>s/", "<Cmd>Telescope search_history<cr>", { desc = "Search History" })
map("n", "<leader>sa", "<Cmd>Telescope autocommands<cr>", { desc = "Autocmds" })
map("n", "<leader>sc", "<Cmd>Telescope command_history<cr>", { desc = "Command History" })
map("n", "<leader>sC", "<Cmd>Telescope commands<cr>", { desc = "Commands" })
map("n", "<leader>sD", "<Cmd>Telescope diagnostics<cr>", { desc = "Buffer Diagnostics" })
map("n", "<leader>sH", "<Cmd>Telescope highlights<cr>", { desc = "Highlights" })
map("n", "<leader>sj", "<Cmd>Telescope jumplist<cr>", { desc = "Jumplist" })
map("n", "<leader>sk", "<Cmd>Telescope keymaps<cr>", { desc = "Keymaps" })
map("n", "<leader>sl", "<Cmd>Telescope loclist<cr>", { desc = "Location List" })
map("n", "<leader>sm", "<Cmd>Telescope marks<cr>", { desc = "Marks" })
map("n", "<leader>sq", "<Cmd>Telescope quickfix<cr>", { desc = "Quickfix List" })

-- ui
map("n", "<leader>uC", "<Cmd>Telescope colorscheme<cr>", { desc = "Color schemes" })

-- typescript
map("n", "<Leader>tn", "<Cmd>lua require('neotest').run.run()<CR>", { desc = "Run nearest test" })
map("n", "<Leader>tf", "<Cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", { desc = "Run test file" })
map("n", "<Leader>tl", "<Cmd>lua require('neotest').run.run_last()<CR>", { desc = "Run last test" })
map("n", "<Leader>td", "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", { desc = "Debug nearest test" })
map("n", "<Leader>ts", "<Cmd>lua require('neotest').summary.toggle()<CR>", { desc = "Toggle test summary" })
map("n", "<Leader>to", "<Cmd>lua require('neotest').output.open()<CR>", { desc = "Show test output" })
map("n", "<Leader>tp", "<Cmd>lua require('neotest').output_panel.toggle()<CR>", { desc = "Toggle output panel" })
map("n", "<Leader>tt", "<Cmd>TailwindConcealToggle<cr>", { desc = "Toggle Tailwind concealing" })
map("n", "<Leader>tt", "<Cmd>TSC<cr>", { desc = "Solution type checking" })

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
