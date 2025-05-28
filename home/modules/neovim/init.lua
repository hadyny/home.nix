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
	virtual_lines = { current_line = true },
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
	window = {
		delay = 0,
		config = {
			width = "auto",
		},
	},
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
		{ mode = "n", keys = "<Leader>b", desc = "buffers" },
		{ mode = "n", keys = "<Leader>f", desc = "files" },
		{ mode = "n", keys = "<Leader>c", desc = "code" },
		{ mode = "n", keys = "<Leader>g", desc = "git" },
		{ mode = "n", keys = "<Leader>s", desc = "search" },
		{ mode = "n", keys = "g", desc = "goto" },
		{ mode = "n", keys = "<Leader>t", desc = "testing" },
		{ mode = "n", keys = "<Leader>d", desc = "debug" },
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

vim.lsp.config("jsonls", { capabilities = capabilities })
vim.lsp.enable("jsonls")

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

require("roslyn").setup({
	exe = "Microsoft.CodeAnalysis.LanguageServer",
})

-- configure dap
local dap = require("dap")
local dapui = require("dapui")

dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

dapui.setup({
	icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
	controls = {
		icons = {
			pause = "⏸",
			play = "▶",
			step_into = "⏎",
			step_over = "⏭",
			step_out = "⏮",
			step_back = "b",
			run_last = "▶▶",
			terminate = "⏹",
			disconnect = "⏏",
		},
	},
})

require("nvim-dap-virtual-text").setup({
	enabled = true, -- enable this plugin (the default)
	enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
	highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
	highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
	show_stop_reason = true, -- show stop reason when stopped for exceptions
	commented = false, -- prefix virtual text with comment string
	only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
	all_references = false, -- show virtual text on all all references of the variable (not only definitions)
	clear_on_continue = false, -- clear virtual text on "continue" (might cause flickering when stepping)
	--- A callback that determines how a variable is displayed or whether it should be omitted
	--- variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
	--- buf number
	--- stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
	--- node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
	--- options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
	--- string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
	display_callback = function(variable, buf, stackframe, node, options)
		if options.virt_text_pos == "inline" then
			return " = " .. variable.value
		else
			return variable.name .. " = " .. variable.value
		end
	end,
	-- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
	virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",

	-- experimental features:
	all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
	virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
	virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
	-- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
})

dap.adapters.coreclr = {
	type = "executable",
	command = "netcoredbg",
	args = { "--interpreter=vscode" },
}
dap.configurations.cs = {
	{
		type = "coreclr",
		name = "launch - netcoredbg",
		request = "launch",
		program = function()
			return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
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
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
map("n", "<leader>k", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
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
map("n", "<Leader>cc", "<Cmd>CopilotChat<cr>", { desc = "Copilot chat" })

-- git
map("n", "<leader>gb", "<Cmd>Gitsigns blame_line<cr>", { desc = "Git Blame" })
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

-- test
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

-- debug
map("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
map("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
map("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
map("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Set Breakpoint" })

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
