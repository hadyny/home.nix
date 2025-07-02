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
options.conceallevel = 2

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
	},
})
vim.cmd.colorscheme("catppuccin-mocha")

map("n", "<Esc>", ":noh<CR><Esc>", { noremap = true, silent = true }) -- escape to cancel search

map("n", "<leader>/", "<Cmd>FzfLua blines<cr>", { desc = "Buffer Lines" })
map("n", "<leader>:", "<Cmd>FzfLua command_history<cr>", { desc = "Command History" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
map("n", "<leader>k", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })

-- file
map("n", "<leader>ff", "<Cmd>FzfLua files<cr>", { desc = "Find Files" })
map("n", "<leader>fr", "<Cmd>FzfLua oldfiles<cr>", { desc = "Recent" })
map("n", "<leader>f+", "<Cmd>set foldlevel=99<cr>", { desc = "Expand all folds" })
map("n", "<leader>f-", "<Cmd>set foldlevel=0<cr>", { desc = "Collapse all folds" })

map("n", "<leader>-", "<Cmd>foldclose<cr>", { desc = "Collapse current fold" })
map("n", "<leader>+", "<Cmd>foldopen<cr>", { desc = "Expand current fold" })

-- Buffer mappings
map("n", "<leader><leader>b", "<Cmd>FzfLua buffers<cr>", { desc = "Switch Buffers" })
map("n", "<leader><leader>[", "<cmd>bprev<CR>", { desc = "Previous buffer" })
map("n", "<leader><leader>]", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader><leader>l", "<cmd>b#<CR>", { desc = "Last buffer" })
map("n", "<leader><leader>d", "<cmd>bdelete<CR>", { desc = "delete buffer" })
map("n", "gb", ":ls<cr>:b<space>", { noremap = true, desc = "Goto buffer" })

-- code
map("n", "<Leader>cr", "<Cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
map("n", "<Leader>cf", "<Cmd>lua vim.lsp.buf.format()<cr>", { desc = "Format buffer" })
map("n", "<Leader>cc", "<Cmd>CopilotChat<cr>", { desc = "Copilot chat" })

-- search
map("n", "<leader>sg", "<Cmd>FzfLua live_grep<cr>", { desc = "Grep project" })
map("n", "<leader>sC", "<Cmd>FzfLua commands<cr>", { desc = "Commands" })
map("n", "<leader>sk", "<Cmd>FzfLua keymaps<cr>", { desc = "Keymaps" })
map("n", "<leader>sm", "<Cmd>FzfLua marks<cr>", { desc = "Marks" })
map("n", "<leader>sp", "<Cmd>FzfLua<cr>", { desc = "Pickers" })

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

				cmdline = { keymap = { preset = "default", ["<CR>"] = { "select_accept_and_enter", "fallback" } } },
			})
		end,
	},
	{
		"fzf-lua",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function(plugin)
			local fzfLua = require("fzf-lua")
			fzfLua.setup({
				{ "default-prompt", "fzf-native" },
				files = {
					code_actions = { previewer = "codeaction_native" },
				},
				previewers = {
					codeaction_native = {
						diff_opts = { ctxlen = 3 },
						pager = [[delta --width=$COLUMNS --hunk-header-style="omit" --file-style="omit"]],
					},
				},
			})
			fzfLua.register_ui_select()
		end,
	},
	{
		"neo-tree.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function(plugin)
			require("neo-tree").setup({
				close_if_last_window = false,
				popup_border_style = "",
				enable_git_status = true,
				enable_diagnostics = true,
				open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
				open_files_using_relative_paths = false,
				sort_case_insensitive = false, -- used when sorting files and directories in the tree

				default_component_configs = {
					container = {
						enable_character_fade = true,
					},
					indent = {
						indent_size = 2,
						padding = 1,
						with_markers = true,
						indent_marker = "│",
						last_indent_marker = "└",
						highlight = "NeoTreeIndentMarker",
						with_expanders = nil,
						expander_collapsed = "",
						expander_expanded = "",
						expander_highlight = "NeoTreeExpander",
					},
					icon = {
						folder_closed = "",
						folder_open = "",
						folder_empty = "󰜌",
						provider = function(icon, node, state) -- default icon provider utilizes nvim-web-devicons if available
							if node.type == "file" or node.type == "terminal" then
								local success, web_devicons = pcall(require, "nvim-web-devicons")
								local name = node.type == "terminal" and "terminal" or node.name
								if success then
									local devicon, hl = web_devicons.get_icon(name)
									icon.text = devicon or icon.text
									icon.highlight = hl or icon.highlight
								end
							end
						end,
						-- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
						-- then these will never be used.
						default = "*",
						highlight = "NeoTreeFileIcon",
					},
					modified = {
						symbol = "[+]",
						highlight = "NeoTreeModified",
					},
					name = {
						trailing_slash = false,
						use_git_status_colors = true,
						highlight = "NeoTreeFileName",
					},
					git_status = {
						symbols = {
							-- Change type
							added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
							modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
							deleted = "✖", -- this can only be used in the git_status source
							renamed = "󰁕", -- this can only be used in the git_status source
							-- Status type
							untracked = "",
							ignored = "",
							unstaged = "󰄱",
							staged = "",
							conflict = "",
						},
					},
					file_size = {
						enabled = true,
						width = 12,
						required_width = 64,
					},
					type = {
						enabled = true,
						width = 10,
						required_width = 122,
					},
					last_modified = {
						enabled = true,
						width = 20,
						required_width = 88,
					},
					created = {
						enabled = true,
						width = 20,
						required_width = 110,
					},
					symlink_target = {
						enabled = false,
					},
				},
				-- A list of functions, each representing a global custom command
				-- that will be available in all sources (if not overridden in `opts[source_name].commands`)
				-- see `:h neo-tree-custom-commands-global`
				commands = {},
				window = {
					position = "right",
					width = 50,
					mapping_options = {
						noremap = true,
						nowait = true,
					},
					mappings = {
						["<space>"] = {
							"toggle_node",
							nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
						},
						["<2-LeftMouse>"] = "open",
						["<cr>"] = "open",
						["<esc>"] = "cancel", -- close preview or floating neo-tree window
						["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
						-- Read `# Preview Mode` for more information
						["l"] = "focus_preview",
						["S"] = "open_split",
						["s"] = "open_vsplit",
						-- ["S"] = "split_with_window_picker",
						-- ["s"] = "vsplit_with_window_picker",
						["t"] = "open_tabnew",
						-- ["<cr>"] = "open_drop",
						-- ["t"] = "open_tab_drop",
						["w"] = "open_with_window_picker",
						--["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
						["C"] = "close_node",
						-- ['C'] = 'close_all_subnodes',
						["z"] = "close_all_nodes",
						--["Z"] = "expand_all_nodes",
						--["Z"] = "expand_all_subnodes",
						["a"] = {
							"add",
							-- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
							-- some commands may take optional config options, see `:h neo-tree-mappings` for details
							config = {
								show_path = "none", -- "none", "relative", "absolute"
							},
						},
						["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
						["d"] = "delete",
						["r"] = "rename",
						["b"] = "rename_basename",
						["y"] = "copy_to_clipboard",
						["x"] = "cut_to_clipboard",
						["p"] = "paste_from_clipboard",
						["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
						-- ["c"] = {
						--  "copy",
						--  config = {
						--    show_path = "none" -- "none", "relative", "absolute"
						--  }
						--}
						["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
						["q"] = "close_window",
						["R"] = "refresh",
						["?"] = "show_help",
						["<"] = "prev_source",
						[">"] = "next_source",
						["i"] = "show_file_details",
					},
				},
				nesting_rules = {},
				filesystem = {
					filtered_items = {
						visible = false, -- when true, they will just be displayed differently than normal items
						hide_dotfiles = true,
						hide_gitignored = true,
						hide_hidden = true, -- only works on Windows for hidden files/directories
						hide_by_name = {
							"node_modules",
						},
						hide_by_pattern = { -- uses glob style patterns
							--"*.meta",
							--"*/src/*/tsconfig.json",
						},
						always_show = { -- remains visible even if other settings would normally hide it
							--".gitignored",
						},
						always_show_by_pattern = { -- uses glob style patterns
							--".env*",
						},
						never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
							--".DS_Store",
							--"thumbs.db"
						},
						never_show_by_pattern = { -- uses glob style patterns
							--".null-ls_*",
						},
					},
					follow_current_file = {
						enabled = false, -- This will find and focus the file in the active buffer every time
						--               -- the current file is changed while the tree is open.
						leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
					},
					group_empty_dirs = false, -- when true, empty folders will be grouped together
					hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
					-- in whatever position is specified in window.position
					-- "open_current",  -- netrw disabled, opening a directory opens within the
					-- window like netrw would, regardless of window.position
					-- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
					use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
					-- instead of relying on nvim autocmd events.
					window = {
						mappings = {
							["<bs>"] = "navigate_up",
							["."] = "set_root",
							["H"] = "toggle_hidden",
							["/"] = "fuzzy_finder",
							["D"] = "fuzzy_finder_directory",
							["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
							-- ["D"] = "fuzzy_sorter_directory",
							["f"] = "filter_on_submit",
							["<c-x>"] = "clear_filter",
							["[g"] = "prev_git_modified",
							["]g"] = "next_git_modified",
							["o"] = {
								"show_help",
								nowait = false,
								config = { title = "Order by", prefix_key = "o" },
							},
							["oc"] = { "order_by_created", nowait = false },
							["od"] = { "order_by_diagnostics", nowait = false },
							["og"] = { "order_by_git_status", nowait = false },
							["om"] = { "order_by_modified", nowait = false },
							["on"] = { "order_by_name", nowait = false },
							["os"] = { "order_by_size", nowait = false },
							["ot"] = { "order_by_type", nowait = false },
							-- ['<key>'] = function(state) ... end,
						},
						fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
							["<down>"] = "move_cursor_down",
							["<C-n>"] = "move_cursor_down",
							["<up>"] = "move_cursor_up",
							["<C-p>"] = "move_cursor_up",
							["<esc>"] = "close",
							-- ['<key>'] = function(state, scroll_padding) ... end,
						},
					},

					commands = {}, -- Add a custom command or override a global one using the same function name
				},
				buffers = {
					follow_current_file = {
						enabled = true, -- This will find and focus the file in the active buffer every time
						--              -- the current file is changed while the tree is open.
						leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
					},
					group_empty_dirs = true, -- when true, empty folders will be grouped together
					show_unloaded = true,
					window = {
						mappings = {
							["d"] = "buffer_delete",
							["bd"] = "buffer_delete",
							["<bs>"] = "navigate_up",
							["."] = "set_root",
							["o"] = {
								"show_help",
								nowait = false,
								config = { title = "Order by", prefix_key = "o" },
							},
							["oc"] = { "order_by_created", nowait = false },
							["od"] = { "order_by_diagnostics", nowait = false },
							["om"] = { "order_by_modified", nowait = false },
							["on"] = { "order_by_name", nowait = false },
							["os"] = { "order_by_size", nowait = false },
							["ot"] = { "order_by_type", nowait = false },
						},
					},
				},
			})

			map("n", "<leader>e", "<Cmd>Neotree toggle<CR>", { desc = "Explorer" })
		end,
	},
	{
		"lualine.nvim",
		enabled = nixCats("general") or false,
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		after = function(plugin)
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "catppuccin",
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = "" },
				},
				sections = {
					lualine_c = {
						{
							"filename",
							path = 1,
							status = true,
						},
					},
				},
				inactive_sections = {
					lualine_b = {
						{
							"filename",
							path = 3,
							status = true,
						},
					},

					lualine_x = { "filetype" },
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
			require("mini.cursorword").setup({ delay = 1000 })
			local MiniIcons = require("mini.icons")
			MiniIcons.setup()
			MiniIcons.mock_nvim_web_devicons()
			MiniIcons.tweak_lsp_kind()
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
		"which-key.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		opts = {
			delay = 0,
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
		after = function(plugin)
			require("which-key").add({
				{
					"<Leader><Leader>",
					group = "buffers",
					expand = function()
						return require("which-key.extras").expand.buf()
					end,
				},
				{ "<Leader>f", group = "files" },
				{ "<Leader>c", group = "code" },
				{ "<Leader>g", group = "git" },
				{ "<Leader>s", group = "search" },
				{ "g", group = "goto" },
				{ "<Leader>t", group = "testing" },
				{ "<Leader>d", group = "debug" },
			})
		end,
	},
	{
		"obsidian.nvim",
		enabled = nixCats("docs") or false,
		event = "DeferredUIEnter",
		ft = "markdown",
		after = function()
			require("obsidian").setup({
				workspaces = {
					{
						name = "personal",
						path = "~/Documents/Vault",
					},
				},
				completion = {
					blink = true,
					min_chars = 2,
					create_new = true,
				},
				picker = {
					name = "fzf-lua",
				},
			})
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
			{ "<leader>db", desc = "Debug: Toggle Breakpoint" },
			{ "<leader>dB", desc = "Debug: Set Breakpoint" },
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
				dap.adapters.netcoredbg = {
					type = "executable",
					command = "netcoredbg",
					args = { "--interpreter=vscode" },
				}
				dap.configurations.cs = {
					{
						type = "netcoredbg",
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
			map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
			map("n", "<leader>dB", function()
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
		enabled = nixCats("docs") or false,
		event = "DeferredUIEnter",
		after = function(plugin)
			require("render-markdown").setup({
				completions = { lsp = { enabled = true } },
			})
		end,
	},
	{
		"tiny-code-action.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			require("tiny-code-action").setup({
				backend = "delta",
				picker = "buffer",
			})
			vim.keymap.set({ "n", "x" }, "<leader>ca", function()
				require("tiny-code-action").code_action({})
			end, { noremap = true, silent = true })
		end,
	},
	{
		"tiny-inline-diagnostic.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function()
			require("tiny-inline-diagnostic").setup({
				multilines = true,
				break_line = { enabled = true },
				enable_on_insert = false,
			})
		end,
	},
	{
		"fidget.nvim",
		enabled = nixCats("general") or false,
		event = "LspAttach",
		after = function ()
			require("fidget").setup({})
		end
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

	-- LSP mappings
	nmap("<leader>sd", "<Cmd>FzfLua lsp_definitions<cr>", "Search definitions")
	nmap("<leader>sr", "<Cmd>FzfLua lsp_references<cr>", "Search References")
	nmap("<leader>si", "<Cmd>FzfLua lsp_implementations<cr>", "Search Implementations")

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

	if nixCats("csharp") then
		vim.treesitter.language.register("c_sharp", "csharp")
	end

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
		"vtsls",
		enabled = nixCats("reactjs") or false,
		lsp = {},
	},
	{
		"fsautocomplete",
		enabled = nixCats("fsharp") or false,
		lsp = {},
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
		"roslyn_ls",
		enabled = nixCats("csharp") or false,
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
