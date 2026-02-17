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
options.completeopt = "menu,preview,noselect,popup"
options.confirm = true
options.showmode = false
options.mouse = "a"
options.winborder = "single"
options.inccommand = "split"
options.conceallevel = 2
options.wrap = false

vim.wo.signcolumn = "yes"
vim.wo.relativenumber = true

-- Decrease update time
options.updatetime = 250
options.timeoutlen = 300

-- Folding
options.foldlevel = 99
options.foldmethod = "expr"
options.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Neovide options
if globals.neovide then
	globals.neovide_padding_top = 30
	globals.neovide_padding_bottom = 30
	globals.neovide_padding_right = 30
	globals.neovide_padding_left = 30
	options.linespace = 7
end

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

vim.api.nvim_create_autocmd("FileType", {
	pattern = "nix",
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
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
map("n", "<Esc>", ":noh<CR><Esc>", { noremap = true, silent = true }) -- escape to cancel search

map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

if nixCats("themes") then
	vim.cmd.colorscheme("catppuccin")
end

if not (nixCats("general")) then
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if client:supports_method("textDocument/completion") then
				vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
			end
		end,
	})
	map("n", "<leader>f+", "<Cmd>set foldlevel=99<cr>", { desc = "Expand all folds" })
	map("n", "<leader>f-", "<Cmd>set foldlevel=0<cr>", { desc = "Collapse all folds" })

	map("n", "<leader>-", "<Cmd>foldclose<cr>", { desc = "Collapse current fold" })
	map("n", "<leader>+", "<Cmd>foldopen<cr>", { desc = "Expand current fold" })

	map("n", "<leader>b[", "<cmd>bprev<CR>", { desc = "Previous buffer" })
	map("n", "<leader><b]", "<cmd>bnext<CR>", { desc = "Next buffer" })
	map("n", "<leader>bl", "<cmd>b#<CR>", { desc = "Last buffer" })
	map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "delete buffer" })
	map("n", "gb", ":ls<cr>:b<space>", { noremap = true, desc = "Goto buffer" })

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
	return
end

require("lze").load({
	{
		"blink.cmp",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		on_require = "blink",
		load = function(name)
			vim.cmd.packadd(name)
			vim.cmd.packadd("lspkind.nvim")
		end,

		after = function(_)
			require("blink.cmp").setup({
				keymap = { preset = "default", ["<CR>"] = { "select_and_accept", "fallback" } },
				appearance = {
					nerd_font_variant = "mono",
				},
				completion = {
					menu = {
						draw = {
							components = {
								kind_icon = {
									text = function(ctx)
										return require("lspkind").symbol_map[ctx.kind] or ""
									end,
								},
							},
						},
					},
					accept = {
						auto_brackets = {
							enabled = true,
						},
					},
					documentation = { auto_show = true, auto_show_delay_ms = 500 },
					ghost_text = { enabled = true },
				},
				signature = { enabled = true },
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
					providers = vim.tbl_extend("force", {}, nixCats("csharp") and {
						["easy-dotnet"] = {
							name = "easy-dotnet",
							enabled = true,
							module = "easy-dotnet.completion.blink",
							score_offset = 10000,
							async = true,
						},
					} or {}, nixCats("docs") and {
						orgmode = {
							name = "Orgmode",
							module = "orgmode.org.autocompletion.blink",
							fallbacks = { "buffer" },
						},
					} or {}),
					per_filetype = {
						nixCats("docs") and { org = { "orgmode" } } or {},
					},
				},
				cmdline = {
					enabled = true,
					keymap = {
						preset = "default",
						["<CR>"] = { "select_accept_and_enter", "fallback" },
					},
					completion = {
						list = { selection = { preselect = false } },
					},
				},
			})
		end,
	},
	{
		"lualine.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function(_)
			require("lualine").setup({
				options = {
					icons_enabled = true,
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
		"bufferline.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function(_)
			require("bufferline").setup({
				highlights = require("catppuccin.special.bufferline").get_theme(),
				options = {
					numbers = "none",
					diagnostics = "nvim_lsp",
					show_buffer_close_icons = false,
					show_close_icon = false,
					separator_style = "thick",
				},
			})
		end,
	},
	{
		"mini.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function(_)
			require("mini.pairs").setup()
			require("mini.cursorword").setup({ delay = 1000 })
			local MiniIcons = require("mini.icons")
			MiniIcons.setup()
			MiniIcons.mock_nvim_web_devicons()
			MiniIcons.tweak_lsp_kind()
		end,
	},
	{
		"which-key.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		opts = {
			delay = 0,
			preset = "helix",
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Keymaps",
			},
		},
		after = function(_) end,
	},
	{
		"gitsigns.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function(_)
			require("gitsigns").setup({
				on_attach = function(_)
					local gs = package.loaded.gitsigns
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
				end,
			})
		end,
	},
	{
		"conform.nvim",
		enabled = nixCats("general") or false,
		after = function(_)
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					lua = nixCats("lua") and { "stylua" } or nil,
					csharp = nixCats("csharp") and { "csharpier" } or nil,
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_format = "fallback",
				},
			})

			options.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
	{
		"yazi.nvim",
		enabled = nixCats("general") or false,
		keys = {
			{
				"<leader>e",
				function()
					require("yazi").yazi()
				end,
				desc = "Yazi",
			},
		},
		event = "DeferredUIEnter",
		after = function()
			require("yazi").setup({
				open_for_directories = true,
			})
		end,
	},
	{
		"snacks.nvim",
		enabled = nixCats("general") or false,
		keys = {
			{
				"<leader><leader>",
				function()
					Snacks.picker.smart()
				end,
				desc = "Find Files",
			},
			{
				"<leader>b",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>/",
				function()
					Snacks.picker.grep()
				end,
				desc = "Search project",
			},
			{
				"<leader>d",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>D",
				function()
					Snacks.picker.diagnostics_buffer()
				end,
				desc = "Buffer Diagnostics",
			},
			{
				"<leader>E",
				function()
					Snacks.picker.explorer()
				end,
				desc = "Tree explorer",
			},
		},
		event = "DeferredUIEnter",
		after = function(_)
			require("snacks").setup({
				picker = {
					sources = {
						explorer = {
							layout = { layout = { position = "right" } },
						},
					},
				},
				input = {},
				terimal = {},
			})
		end,
	},
	{
		"render-markdown.nvim",
		enabled = nixCats("docs") or false,
		event = "DeferredUIEnter",
		after = function(_)
			require("render-markdown").setup({
				completions = { lsp = { enabled = true } },
			})
		end,
	},
	{
		"fidget.nvim",
		enabled = nixCats("general") or false,
		event = "LspAttach",
		after = function()
			require("fidget").setup({})
		end,
	},
	{
		"nvim-highlight-colors",
		enabled = nixCats("reactjs") or false,
		event = "DeferredUIEnter",
		after = function(_)
			require("nvim-highlight-colors").setup({
				render = "background",
			})
		end,
	},
	{
		"easy-dotnet.nvim",
		enabled = nixCats("csharp") or false,
		-- on_plugin = { "nvim-dap" },
		event = "LspAttach",
		ft = "cs",
		load = function(name)
			vim.cmd.packadd(name)
			vim.cmd.packadd("nvim-dap")
			vim.cmd.packadd("nvim-dap-ui")
			vim.cmd.packadd("nvim-dap-virtual-text")
		end,

		after = function(_)
			local dap = require("dap")
			local dapui = require("dapui")
			map("n", "q", function()
				dap.terminate()
				dap.clear_breakpoints()
			end, { desc = "Terminate and clear breakpoints" })

			-- Basic debugging keymaps, feel free to change to your liking!
			map("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
			map("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
			map("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
			map("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
			map("n", "<leader>B", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })

			-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
			map("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })

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
			})

			require("easy-dotnet").setup({
				picker = "snacks",
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
	{
		"diffview.nvim",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		after = function(_)
			require("diffview").setup({})
		end,
	},
	{
		"neogit",
		enabled = nixCats("general") or false,
		event = "DeferredUIEnter",
		keys = {
			{
				"<leader>g",
				"<cmd>Neogit<cr>",
				desc = "Command History",
			},
		},
		after = function(_)
			require("neogit").setup({})
		end,
	},
	{
		"tiny-code-action.nvim",
		enabled = nixCats("general") or false,
		event = "LspAttach",
		after = function(_)
			require("tiny-code-action").setup({
				backend = "delta",
				picker = "buffer",
			})
			map({ "n", "x" }, "<leader>a", function()
				require("tiny-code-action").code_action({})
			end, { noremap = true, silent = true, desc = "Code action" })
		end,
	},
	{
		"tiny-inline-diagnostic.nvim",
		enabled = nixCats("general") or false,
		event = "LspAttach",
		after = function(_)
			require("tiny-inline-diagnostic").setup({
				multilines = true,
				break_line = { enabled = true },
				enable_on_insert = false,
			})
		end,
	},
	{
		"orgmode",
		enabled = nixCats("docs") or false,
		load = function(name)
			vim.cmd.packadd(name)
			vim.cmd.packadd("org-modern.nvim")
		end,
		keys = {
			{ "<leader>oa", "<cmd>Org agenda<cr>", desc = "Org agenda" },
			{ "<leader>oc", "<cmd>Org capture<cr>", desc = "Org capture" },
		},
		after = function(_)
			local Menu = require("org-modern.menu")
			require("orgmode").setup({
				win_split_mode = "auto",
				org_agenda_files = "~/org/**/*",
				org_default_notes_file = "~/org/notes.org",
				org_hide_leading_stars = true,
				org_todo_keywords = { "TODO", "IN-PROGRESS", "WAITING", "|", "DONE", "WONT-DO" },
				org_todo_keyword_faces = {
					TODO = ":foreground #DAA520 :weight bold",
					["IN-PROGRESS"] = ":foreground #00FFFF :slant italic",
					WAITING = ":foreground #FF8C00",
					DONE = ":foreground #32CD32",
					["WONT-DO"] = ":foreground #32CD32",
				},
				ui = {
					menu = {
						handler = function(data)
							Menu:new({
								window = {
									margin = { 1, 0, 1, 0 },
									padding = { 0, 1, 0, 1 },
									title_pos = "center",
									border = "single",
									zindex = 1000,
								},
								icons = {
									separator = "➜",
								},
							}):open(data)
						end,
					},
				},
				mappings = {
					global = {
						org_agenda = "oa",
						org_capture = "X",
					},
				},
				org_capture_templates = {
					t = {
						description = "Todo",
						template = "** TODO [#B] %?\nCreated: %T\n %u",
						target = "~/org/todo.org",
					},
					c = {
						description = "Code Todo",
						template = "** TODO [#B] %?\nCreated: %T\n %u\n%i\n%a\nProposed Solution: ",
						target = "~/org/todo.org",
					},
					e = "Event",
					er = {
						description = "Recurring Event",
						template = "** EVENT %?\n %T",
						target = "~/org/calendar.org",
						headline = "Recurring Events",
					},
					eo = {
						description = "One-off Event",
						template = "** EVENT %?\n%i\n",
						target = "~/org/schedule.org",
						headline = "Events",
					},
					w = {
						description = "Work log",
						template = "* %?",
						target = "~/org/work-log.org",
						datetree = true,
					},
					n = {
						description = "Notes",
						template = "* %?",
						target = "~/org/notes.org",
					},
				},
				org_agenda_custom_commands = {
					c = {
						description = "Current Work",
						types = {
							{
								type = "tags",
								match = '+work+PRIORITY="A"-TODO="DONE"',
								org_agenda_overriding_header = "High priority todos",
								org_agenda_todo_ignore_deadlines = "far",
							},
							{
								type = "tags",
								match = '+work-PRIORITY="A"-TODO="DONE"',
								org_agenda_overriding_header = "Other todos",
								org_agenda_todo_ignore_deadlines = "far",
							},
							{
								type = "agenda",
								org_agenda_overriding_header = "Previous work",
								org_agenda_start_on_weekday = false,
								org_agenda_start_day = "-2d",
								org_agenda_remove_tags = true, -- Do not show tags only for this view
							},
						},
					},
					S = {
						description = "Standup",
						types = {
							{
								type = "agenda",
								match = '+work+TODO="DONE"',
								org_agenda_overriding_header = "Did yesterday",
								org_agenda_todo_ignore_deadlines = "far",
								org_agenda_start_on_weekday = false,
								org_agenda_start_day = "-1d",
								org_agenda_remove_tags = true,
							},
							{
								type = "tags",
								match = '+work+TODO="IN-PROGRESS"',
								org_agenda_overriding_header = "Doing",
								org_agenda_remove_tags = true,
							},
							{
								type = "tags",
								match = '+work+TODO="WAITING"',
								org_agenda_overriding_header = "Blocked",
								org_agenda_remove_tags = true,
							},
							{
								type = "tags",
								match = '+work+TODO="TODO"',
								org_agenda_overriding_header = "To do",
								org_agenda_remove_tags = true,
							},
						},
					},
					w = {
						description = "Week Overview",
						types = {
							{
								type = "agenda",
								org_agenda_overriding_header = "Whole week overview",
								org_agenda_span = "week", -- 'week' is default, so it's not necessary here, just an example
								org_agenda_start_on_weekday = 1, -- Start on Monday
								org_agenda_remove_tags = true, -- Do not show tags only for this view
							},
						},
					},
					o = {
						description = "Combined Overview", -- Description shown in the prompt for the shortcut
						types = {
							{
								type = "tags", -- Type can be agenda | tags | tags_todo
								match = '+PRIORITY="A"-TODO="DONE"', --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
								org_agenda_overriding_header = "High priority todos",
								org_agenda_todo_ignore_deadlines = "far", -- Ignore all deadlines that are too far in future (over org_deadline_warning_days). Possible values: all | near | far | past | future
							},
							{
								type = "agenda",
								org_agenda_overriding_header = "Today",
								org_agenda_span = "day", -- can be any value as org_agenda_span
							},
							{
								type = "tags",
								match = '+work-TODO="DONE"', --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
								org_agenda_overriding_header = "Work tasks",
								-- org_agenda_todo_ignore_scheduled = 'all', -- Ignore all headlines that are scheduled. Possible values: past | future | all
							},
							{
								type = "tags",
								match = '-work-TODO="DONE"', --Same as providing a "Match:" for tags view <leader>oa + m, See: https://orgmode.org/manual/Matching-tags-and-properties.html
								org_agenda_overriding_header = "Personal tasks",
								org_agenda_files = { "~/org/todo.org" },
								-- org_agenda_todo_ignore_scheduled = 'all', -- Ignore all headlines that are scheduled. Possible values: past | future | all
							},
						},
					},
				},
			})
		end,
	},
	{
		"opencode.nvim",
		enabled = nixCats("ai") or false,
		load = function(name)
			vim.cmd.packadd(name)
			vim.cmd.packadd("snacks.nvim")
		end,
		after = function(_)
			options.autoread = true
			map({ "n", "x" }, "<C-a>", function()
				require("opencode").ask("@this: ", { submit = true })
			end, { desc = "Ask opencode…" })
			map({ "n", "x" }, "<C-x>", function()
				require("opencode").select()
			end, { desc = "Execute opencode action…" })
			map({ "n", "t" }, "<C-.>", function()
				require("opencode").toggle()
			end, { desc = "Toggle opencode" })

			map({ "n", "x" }, "go", function()
				return require("opencode").operator("@this ")
			end, { desc = "Add range to opencode", expr = true })
			map("n", "goo", function()
				return require("opencode").operator("@this ") .. "_"
			end, { desc = "Add line to opencode", expr = true })

			map("n", "<S-C-u>", function()
				require("opencode").command("session.half.page.up")
			end, { desc = "Scroll opencode up" })
			map("n", "<S-C-d>", function()
				require("opencode").command("session.half.page.down")
			end, { desc = "Scroll opencode down" })
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

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
	map("n", "gr", function()
		Snacks.picker.lsp_references()
	end, { desc = "Goto References" })
	map("n", "gI", function()
		Snacks.picker.lsp_implementations()
	end, { desc = "Goto Implementations" })
	map("n", "gd", function()
		Snacks.picker.lsp_definitions()
	end, { desc = "Goto Definitions" })
	map("n", "gy", function()
		Snacks.picker.lsp_type_definitions()
	end, { desc = "Goto Type Definitions" })

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
						globals = { "nixCats", "vim", "Snacks" },
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
		lsp = {
			filetypes = {
				"graphql",
			},
		},
		enabled = nixCats("reactjs") or false,
	},
	{
		"jsonls",
		lsp = {},
		enabled = nixCats("reactjs") or false,
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
						command = { "nixfmt" },
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
