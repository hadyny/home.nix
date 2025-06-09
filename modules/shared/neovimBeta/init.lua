local vim = vim
local options = vim.o
local globals = vim.g
local diagnostics = vim.diagnostic

globals.mapleader = " "
globals.maplocalleader = " "
globals.netrw_liststyle = 0
globals.netrw_banner = 0

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

vim.wo.signcolumn = "yes"
vim.wo.relativenumber = true

-- Decrease update time
options.updatetime = 250
options.timeoutlen = 300

-- Folding
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

-- [[ Disable auto comment on enter ]]
-- See :help formatoptions
vim.api.nvim_create_autocmd("FileType", {
	desc = "remove formatoptions",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
local map = vim.keymap.set
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Moves Line Down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Moves Line Up" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up" })
map("n", "n", "nzzzv", { desc = "Next Search Result" })
map("n", "N", "Nzzzv", { desc = "Previous Search Result" })

-- Remap for dealing with word wrap
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

map({ "v", "x", "n" }, "<leader>y", '"+y', { noremap = true, silent = true, desc = "Yank to clipboard" })
map({ "n", "v", "x" }, "<leader>Y", '"+yy', { noremap = true, silent = true, desc = "Yank line to clipboard" })
map({ "n", "v", "x" }, "<leader>p", '"+p', { noremap = true, silent = true, desc = "Paste from clipboard" })
map(
	"i",
	"<C-p>",
	"<C-r><C-p>+",
	{ noremap = true, silent = true, desc = "Paste from clipboard from within insert mode" }
)
map(
	"x",
	"<leader>P",
	'"_dP',
	{ noremap = true, silent = true, desc = "Paste over selection without erasing unnamed register" }
)
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
		snacks = {
			enabled = true,
			indent_scope_color = "lavender",
		},
	},
})
vim.cmd.colorscheme("catppuccin-mocha")
require("snacks").setup({
	explorer = { enabled = true },
	terminal = { enabled = true },
	animate = { enabled = true },
	dim = { enabled = true },
	image = { enabled = true },
	notifier = { enabled = true },
	rename = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	picker = { enabled = true },
	words = { enabled = true },
})

map("n", "<Esc>", ":noh<CR><Esc>", { noremap = true, silent = true }) -- escape to cancel search

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
map("n", "<leader><leader>b", "<Cmd>Pick buffers<cr>", { desc = "Switch Buffers" })
map("n", "<leader><leader>[", "<cmd>bprev<CR>", { desc = "Previous buffer" })
map("n", "<leader><leader>]", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader><leader>l", "<cmd>b#<CR>", { desc = "Last buffer" })
map("n", "<leader><leader>d", "<cmd>bdelete<CR>", { desc = "delete buffer" })
map("n", "gb", ":ls<cr>:b<space>", { noremap = true, desc = "Goto buffer" })

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

require("lze").load({
	{
		"blink.cmp",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		on_require = "blink",
		after = function(plugin)
			require("blink.cmp").setup({
				-- See :h blink-cmp-config-keymap for configuring keymaps
				keymap = { preset = "default", ["<CR>"] = { "select_and_accept", "fallback" } },
				appearance = {
					nerd_font_variant = "mono",
				},
				signature = { enabled = true },
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
				},
			})
		end,
	},
	{
		"nvim-treesitter",
		enabled = nixCats("general") or false,
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		load = function(name)
			vim.cmd.packadd(name)
			vim.cmd.packadd("nvim-treesitter-textobjects")
		end,
		after = function(plugin)
			-- [[ Configure Treesitter ]]
			-- See `:help nvim-treesitter`
			require("nvim-treesitter.configs").setup({
				highlight = { enable = true },
				indent = { enable = false },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<c-space>",
						node_incremental = "<c-space>",
						scope_incremental = "<c-s>",
						node_decremental = "<M-space>",
					},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]m"] = "@function.outer",
							["]]"] = "@class.outer",
						},
						goto_next_end = {
							["]M"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[["] = "@class.outer",
						},
						goto_previous_end = {
							["[M"] = "@function.outer",
							["[]"] = "@class.outer",
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["<leader>a"] = "@parameter.inner",
						},
						swap_previous = {
							["<leader>A"] = "@parameter.inner",
						},
					},
				},
			})
		end,
	},
	{
		"mini.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function(plugin)
			require("mini.pairs").setup()
			require("mini.ai").setup()
			local MiniIcons = require("mini.icons")
			MiniIcons.setup()
			MiniIcons.mock_nvim_web_devicons()
			MiniIcons.tweak_lsp_kind()
			require("mini.pick").setup()
			require("mini.extra").setup()
			require("mini.git").setup()
			require("mini.diff").setup()
			require("mini.statusline").setup({ use_icons = true })
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
		end,
	},
	{
		"vim-startuptime",
		enabled = nixCats("general") or false,
		cmd = { "StartupTime" },
		before = function(_)
			vim.g.startuptime_event_width = 0
			vim.g.startuptime_tries = 10
			vim.g.startuptime_exe_path = nixCats.packageBinPath
		end,
	},
	{
		"gitsigns.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		-- cmd = { "" },
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		after = function(plugin)
			require("gitsigns").setup({
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map({ "n", "v" }, "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Jump to next hunk" })

					map({ "n", "v" }, "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Jump to previous hunk" })

					-- Actions
					-- visual mode
					map("v", "<leader>hs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "stage git hunk" })
					map("v", "<leader>hr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "reset git hunk" })
					-- normal mode
					map("n", "<leader>gs", gs.stage_hunk, { desc = "git stage hunk" })
					map("n", "<leader>gr", gs.reset_hunk, { desc = "git reset hunk" })
					map("n", "<leader>gS", gs.stage_buffer, { desc = "git Stage buffer" })
					map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
					map("n", "<leader>gR", gs.reset_buffer, { desc = "git Reset buffer" })
					map("n", "<leader>gp", gs.preview_hunk, { desc = "preview git hunk" })
					map("n", "<leader>gb", function()
						gs.blame_line({ full = false })
					end, { desc = "git blame line" })
					map("n", "<leader>gd", gs.diffthis, { desc = "git diff against index" })
					map("n", "<leader>gD", function()
						gs.diffthis("~")
					end, { desc = "git diff against last commit" })

					-- Toggles
					map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
					map("n", "<leader>gtd", gs.toggle_deleted, { desc = "toggle git show deleted" })

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
				end,
			})
			vim.cmd([[hi GitSignsAdd guifg=#04de21]])
			vim.cmd([[hi GitSignsChange guifg=#83fce6]])
			vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
		end,
	},
	{
		"nvim-lint",
		enabled = nixCats("general") or false,
		event = "FileType",
		after = function(plugin)
			require("lint").linters_by_ft = {
				-- NOTE: download some linters in lspsAndRuntimeDeps
				-- and configure them here
				-- markdown = {'vale',},
				javascript = nixCats("reactjs") and { "eslint" } or nil,
				typescript = nixCats("reactjs") and { "eslint" } or nil,
				go = nixCats("go") and { "golangcilint" } or nil,
			}

			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
	{
		"conform.nvim",
		enabled = nixCats("general") or false,
		keys = {
			{ "<leader>cf", desc = "[c]ode [f]ormat" },
		},
		after = function(plugin)
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					lua = nixCats("lua") and { "stylua" } or nil,
					go = nixCats("go") and { "gofmt", "golint" } or nil,
					typescript = nixCats("reactjs") and { "prettier" } or nil,
					typescriptreact = nixCats("reactjs") and { "prettier" } or nil,
					csharp = nixCats("csharp") and { "csharpier" } or nil,
				},
			})

			options.formatexpr = "v:lua.require'conform'.formatexpr()"

			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = " [c]ode [f]ormat" })
		end,
	},
	{
		"nvim-dap",
		enabled = nixCats("general") or false,
		-- cmd = { "" },
		-- event = "",
		-- ft = "",
		keys = {
			{ "<F5>", desc = "Debug: Start/Continue" },
			{ "<F1>", desc = "Debug: Step Into" },
			{ "<F2>", desc = "Debug: Step Over" },
			{ "<F3>", desc = "Debug: Step Out" },
			{ "<leader>b", desc = "Debug: Toggle Breakpoint" },
			{ "<leader>B", desc = "Debug: Set Breakpoint" },
			{ "<F7>", desc = "Debug: See last session result." },
		},
		-- colorscheme = "",
		load = function(name)
			vim.cmd.packadd(name)
			vim.cmd.packadd("nvim-dap-ui")
			vim.cmd.packadd("nvim-dap-virtual-text")
		end,
		after = function(plugin)
			local dap = require("dap")
			local dapui = require("dapui")

			if nixCats("csharp") then
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
			end

			if nixCats("reactjs") then
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
			end

			-- Basic debugging keymaps, feel free to change to your liking!
			map("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
			map("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
			map("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
			map("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
			map("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
			map("n", "<leader>B", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Debug: Set Breakpoint" })

			-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
			map("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })

			dap.listeners.after.event_initialized["dapui_config"] = dapui.open
			dap.listeners.before.event_terminated["dapui_config"] = dapui.close
			dap.listeners.before.event_exited["dapui_config"] = dapui.close

			-- Dap UI setup
			-- For more information, see |:help nvim-dap-ui|
			dapui.setup({
				-- Set icons to characters that are more likely to work in every terminal.
				--    Feel free to remove or use ones that you like more! :)
				--    Don't feel like these are good choices.
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

			-- NOTE: Install lang specific config
			-- either in here, or in a separate plugin spec as demonstrated for go below.
		end,
	},
	{
		"nvim-dap-go",
		enabled = nixCats("go") or false,
		on_plugin = { "nvim-dap" },
		after = function(plugin)
			require("dap-go").setup()
		end,
	},
	{
		"roslyn.nvim",
		enabled = nixCats("csharp") or false,
		event = "LspAttach",
		after = function(plugin)
			require("roslyn").setup({
				exe = "Microsoft.CodeAnalysis.LanguageServer",
			})
		end,
	},
	{
		"typescript-tools.nvim",
		enabled = nixCats("reactjs") or false,
		event = "LspAttach",
		after = function(plugin)
			require("typescript-tools").setup({})
		end,
	},
	{
		"tailwind-tools.nvim",
		enabled = nixCats("reactjs") or false,
		event = "LspAttach",
		after = function(plugin)
			require("tailwind-tools").setup({
				document_color = { enabled = false },
				conceal = {
					enabled = true,
					min_length = 10,
				},
			})
		end,
	},
	{
		"render-markdown.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		load = function(name)
			vim.cmd.packadd(name)
		end,
		after = function(plugin)
			require("render-markdown").setup({
				completions = { lsp = { enabled = true } },
			})
		end,
	},
	{
		"CopilotChat.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function(plugin)
			require("CopilotChat").setup({})
		end,
	},
	{
		"nvim-highlight-colors",
		enabled = nixCats("reactjs") or false,
		event = "DeferredUIEnter",
		after = function(plugin)
			require("nvim-highlight-colors").setup({
				enable_tailwind = true,
				render = "background",
			})
		end,
	},
	{
		"neotest",
		enabled = nixCats("reactjs") or nixCats("csharp") or false,
		event = "DeferredUIEnter",
		load = function(name)
			vim.cmd.packadd(name)
			vim.cmd.packadd("neotest-vitest")
			vim.cmd.packadd("neotest-dotnet")
		end,
		after = function(plugin)
			require("neotest").setup({
				adapters = {
					require("neotest-vitest"),
					require("neotest-dotnet")({
						dap = { justMyCode = false },
					}),
				},
			})
		end,
	},
	{
		"lazydev.nvim",
		enabled = nixCats("lua") or false,
		cmd = { "LazyDev" },
		ft = "lua",
		after = function(_)
			require("lazydev").setup({
				library = {
					{ words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. "/lua" },
				},
			})
		end,
	},
})

local function lsp_on_attach(_, bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")

	nmap("]d", vim.lsp.diagnostic.goto_next, "Next diagnostic")
	nmap("[d", vim.lsp.diagnostic.goto_prev, "Previous diagnostic")

	if nixCats("general") then
		nmap("gr", function()
			Snacks.picker.lsp_references()
		end, "[G]oto [R]eferences")
		nmap("gI", function()
			Snacks.picker.lsp_implementations()
		end, "[G]oto [I]mplementation")
		nmap("<leader>ds", function()
			Snacks.picker.lsp_symbols()
		end, "[D]ocument [S]ymbols")
		nmap("<leader>ws", function()
			Snacks.picker.lsp_workspace_symbols()
		end, "[W]orkspace [S]ymbols")
	end

	nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

	-- Lesser used LSP functionality
	nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
	nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
	nmap("<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })
end

-- NOTE: Register a handler from lzextras. This one makes it so that
-- you can set up lsps within lze specs,
-- and trigger vim.lsp.enable and the rtp config collection only on the correct filetypes
-- it adds the lsp field used below
-- (and must be registered before any load calls that use it!)
require("lze").register_handlers(require("lzextras").lsp)
-- also replace the fallback filetype list retrieval function with a slightly faster one
require("lze").h.lsp.set_ft_fallback(function(name)
	return dofile(nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) .. "/lsp/" .. name .. ".lua").filetypes
		or {}
end)
require("lze").load({
	{
		"nvim-lspconfig",
		enabled = nixCats("general") or false,
		-- the on require handler will be needed here if you want to use the
		-- fallback method of getting filetypes if you don't provide any
		on_require = { "lspconfig" },
		-- define a function to run over all type(plugin.lsp) == table
		-- when their filetype trigger loads them
		lsp = function(plugin)
			vim.lsp.config(plugin.name, plugin.lsp or {})
			vim.lsp.enable(plugin.name)
		end,
		before = function(_)
			vim.lsp.config("*", {
				on_attach = lsp_on_attach,
			})
		end,
	},
	{
		"lua_ls",
		enabled = nixCats("lua") or false,
		lsp = {
			filetypes = { "lua" },
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					formatters = {
						ignoreComments = true,
					},
					signatureHelp = { enabled = true },
					diagnostics = {
						globals = { "nixCats", "vim" },
						disable = { "missing-fields" },
					},
					telemetry = { enabled = false },
				},
			},
		},
	},
	{
		"eslint",
		enabled = nixCats("reactjs") or false,
		lsp = {
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
				"graphql",
			},
		},
	},
	{
		"tailwindcss",
		lsp = {},
		enabled = nixCats("reactjs") or false,
	},
	{
		"graphql",
		lsp = {},
		enabled = nixCats("reactjs") or false,
	},
	{
		"jsonls",
		lsp = {},
		enabled = nixCats("reactjs") or false,
	},
	{
		"gopls",
		enabled = nixCats("go") or false,
		lsp = {},
	},
	{
		"nixd",
		enabled = nixCats("nix") or false,
		lsp = {
			filetypes = { "nix" },
			settings = {
				nixd = {
					-- nixd requires some configuration.
					-- luckily, the nixCats plugin is here to pass whatever we need!
					-- we passed this in via the `extra` table in our packageDefinitions
					-- for additional configuration options, refer to:
					-- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
					nixpkgs = {
						-- in the extras set of your package definition:
						-- nixdExtras.nixpkgs = ''import ${pkgs.path} {}''
						expr = nixCats.extra("nixdExtras.nixpkgs") or [[import <nixpkgs> {}]],
					},
					options = {
						nixos = {
							-- nixdExtras.nixos_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").nixosConfigurations.configname.options''
							expr = nixCats.extra("nixdExtras.nixos_options"),
						},
						["home-manager"] = {
							-- nixdExtras.home_manager_options = ''(builtins.getFlake "path:${builtins.toString inputs.self.outPath}").homeConfigurations.configname.options''
							expr = nixCats.extra("nixdExtras.home_manager_options"),
						},
					},
					formatting = {
						command = { "alejandra" },
					},
					diagnostic = {
						suppress = {
							"sema-escaping-with",
						},
					},
				},
			},
		},
	},
})
