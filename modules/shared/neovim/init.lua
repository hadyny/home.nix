local vim = vim
local options = vim.o
local globals = vim.g
local diagnostics = vim.diagnostic
local vscode = vim.g.vscode

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
if nixCats("general") or nixCats("miniNvim") and not vscode then
    vim.cmd.colorscheme("tokyonight-night")
end
map("n", "<Esc>", ":noh<CR><Esc>", { noremap = true, silent = true }) -- escape to cancel search

map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
map("n", "<leader>k", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })

-- file
map("n", "<leader>f+", "<Cmd>set foldlevel=99<cr>", { desc = "Expand all folds" })
map("n", "<leader>f-", "<Cmd>set foldlevel=0<cr>", { desc = "Collapse all folds" })

map("n", "<leader>-", "<Cmd>foldclose<cr>", { desc = "Collapse current fold" })
map("n", "<leader>+", "<Cmd>foldopen<cr>", { desc = "Expand current fold" })

-- Buffer mappings
map("n", "<leader>b[", "<cmd>bprev<CR>", { desc = "Previous buffer" })
map("n", "<leader><b]", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bl", "<cmd>b#<CR>", { desc = "Last buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "delete buffer" })
map("n", "gb", ":ls<cr>:b<space>", { noremap = true, desc = "Goto buffer" })

-- code
map("n", "<Leader>cr", "<Cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
map("n", "<Leader>cf", "<Cmd>lua vim.lsp.buf.format()<cr>", { desc = "Format buffer" })

if not nixCats("general") and not nixCats("miniNvim") then
    return
end

require("lze").load({
    {
        "mini.nvim",
        enabled = (nixCats("miniNvim") and not vscode) or false,
        event = "DeferredUIEnter",
        load = function(name)
            vim.cmd.packadd(name)
            vim.cmd.packadd("mini.nvim")
        end,
        after = function(plugin)
            require("mini.ai").setup()
            require("mini.comment").setup()
            require("mini.completion").setup()
            require("mini.pairs").setup()
            require("mini.basics").setup()
            require("mini.bufremove").setup()
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
                    -- Enhance this by adding descriptions for <Leader> mapping groups
                    miniclue.gen_clues.builtin_completion(),
                    miniclue.gen_clues.g(),
                    miniclue.gen_clues.marks(),
                    miniclue.gen_clues.registers(),
                    miniclue.gen_clues.windows(),
                    miniclue.gen_clues.z(),
                },
            })
            require("mini.diff").setup()
            require("mini.git").setup()
            require("mini.cursorword").setup({ delay = 1000 })
            local MiniIcons = require("mini.icons")
            MiniIcons.setup()
            MiniIcons.mock_nvim_web_devicons()
            MiniIcons.tweak_lsp_kind()
            require("mini.notify").setup()
            require("mini.statusline").setup()
            require("mini.pick").setup()
            require("mini.extra").setup()
        end,
    },
    {
        "blink.cmp",
        enabled = (nixCats("general") and not vscode) or false,
        event = "DeferredUIEnter",
        on_require = "blink",
        load = function(name)
            vim.cmd.packadd(name)
            -- vim.cmd.packadd("blink-cmp-avante")
        end,

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
                    -- default = { "avante", "lsp", "path", "snippets", "buffer" },
                    -- providers = {
                    --     avante = {
                    --         module = "blink-cmp-avante",
                    --         name = "Avante",
                    --         opts = {},
                    --     },
                    -- },
                },
                cmdline = { keymap = { preset = "default", ["<CR>"] = { "select_accept_and_enter", "fallback" } } },
            })
        end,
    },
    {
        "snacks.nvim",
        enabled = (nixCats("general") and not vscode) or false,
        after = function(plugin)
            local snacks = require("snacks")
            snacks.setup({
                animate = { enabled = true },
                bigfile = { enabled = true },
                explorer = { enabled = true },
                input = { enabled = true },
                lazygit = { enabled = true },
                picker = {
                    enabled = true,
                    sources = { explorer = { layout = { layout = { position = "right" } } } },
                },
                quickfile = { enabled = true },
                rename = { enabled = true },
                scope = { enabled = true },
                scroll = { enabled = true },
                -- statuscolumn = { enabled = true },
            })
            map("n", "<leader>e", function()
                snacks.picker.explorer()
            end, { desc = "Explorer" })
            map("n", "<leader><leader>", function()
                snacks.picker.smart()
            end, { desc = "Smart Fuzzy Find" })
            map("n", "<leader>ff", function()
                snacks.picker.files({ hidden = true })
            end, { desc = "Fuzzy find files" })
            map("n", "<leader>fr", function()
                snacks.picker.recent()
            end, { desc = "Fuzzy find recent files" })
            map("n", "<leader>sg", function()
                snacks.picker.grep()
            end, { desc = "Find string in CWD" })
            map("n", "<leader>sc", function()
                snacks.picker.grep_word()
            end, { desc = "Find word under cursor in CWD" })
            map("n", "<leader>bs", function()
                snacks.picker.buffers({ layout = { preset = "select" } })
            end, { desc = "Fuzzy find buffers" })
            map("n", "<leader>ft", function()
                snacks.picker()
            end, { desc = "Other pickers..." })
            map("n", "<leader>h", function()
                snacks.picker.help()
            end, { desc = "Find help tags" })
            map("n", "<leader>go", function()
                snacks.gitbrowse()
            end, { desc = "Open file online" })
            map("n", "<leader>sh", function()
                snacks.picker.search_history()
            end, { desc = "Search History" })
            map("n", "<leader>/", function()
                snacks.picker.lines()
            end, { desc = "Buffer Lines" })
            map("n", "<leader>gg", function()
                snacks.lazygit.open()
            end, { desc = "Lazygit" })
            map("n", "<leader>gl", function()
                snacks.lazygit.log_file()
            end, { desc = "Git log for current file" })
            map("n", "<leader>gL", function()
                snacks.lazygit.log()
            end, { desc = "Git log" })
        end,
    },
    {
        "lualine.nvim",
        enabled = (nixCats("general") and not vscode) or false,
        -- cmd = { "" },
        event = "DeferredUIEnter",
        -- ft = "",
        -- keys = "",
        -- colorscheme = "",
        after = function(plugin)
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
        enabled = (nixCats("general") and not vscode) or false,
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
                    "<Leader>b",
                    group = "buffers",
                    expand = function()
                        return require("which-key.extras").expand.buf()
                    end,
                },
                { "<Leader>a", group = "ai" },
                { "<Leader>f", group = "files" },
                { "<Leader>c", group = "code" },
                { "<Leader>g", group = "git" },
                { "<Leader>s", group = "search" },
                { "g",         group = "goto" },
                { "<Leader>t", group = "testing" },
                { "<Leader>d", group = "debug" },
            })
        end,
    },
    {
        "obsidian.nvim",
        enabled = (nixCats("docs") and not vscode) or false,
        event = "DeferredUIEnter",
        ft = "markdown",
        after = function()
            require("obsidian").setup({
                legacy_commands = false,
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
                    name = "snacks.pick",
                },
            })
        end,
    },
    {
        "gitsigns.nvim",
        enabled = (nixCats("general") and not vscode) or false,
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
            { "<leader>cf", desc = "Code format" },
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
            end, { desc = " Code format" })
        end,
    },
    {
        "nvim-dap",
        enabled = nixCats("general") or false,
        -- cmd = { "" },
        -- event = "",
        -- ft = "",
        keys = {
            { "<F5>",       desc = "Debug: Start/Continue" },
            { "<F1>",       desc = "Debug: Step Into" },
            { "<F2>",       desc = "Debug: Step Over" },
            { "<F3>",       desc = "Debug: Step Out" },
            { "<leader>db", desc = "Debug: Toggle Breakpoint" },
            { "<leader>dB", desc = "Debug: Set Breakpoint" },
            { "<F7>",       desc = "Debug: See last session result." },
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
                enabled = true,                     -- enable this plugin (the default)
                enabled_commands = true,            -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
                highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
                highlight_new_as_changed = false,   -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
                show_stop_reason = true,            -- show stop reason when stopped for exceptions
                commented = false,                  -- prefix virtual text with comment string
                only_first_definition = true,       -- only show virtual text at first definition (if there are multiple)
                all_references = false,             -- show virtual text on all all references of the variable (not only definitions)
                clear_on_continue = false,          -- clear virtual text on "continue" (might cause flickering when stepping)
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
                all_frames = false,      -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
                virt_lines = false,      -- show virtual lines instead of virtual text (will flicker!)
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
            map({ "n", "x" }, "<leader>ca", function()
                require("tiny-code-action").code_action({})
            end, { noremap = true, silent = true, desc = "Code action" })
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
        after = function()
            require("fidget").setup({})
        end,
    },
    {
        "quicker.nvim",
        enabled = nixCats("general") or false,
        event = "LspAttach",
        after = function()
            require("quicker").setup()
            map("n", "<leader>q", "<Cmd>lua require('quicker').toggle()<cr>", { desc = "Toggle quickfix" })
        end,
    },
    {
        "avante.nvim",
        enabled = nixCats("ai") or false,
        event = "LspAttach",
        after = function()
            require("avante").setup({
                input = {
                    provider = "snacks",
                    provider_opts = {
                        title = "Avante Input",
                        icon = " ",
                        placeholder = "Enter your API key...",
                    },
                },
                windows = {
                    position = "left",
                    width = 40,
                },
            })
        end,
    },
    {
        "CopilotChat.nvim",
        enabled = nixCats("general") or false,
        event = "DeferredUIEnter",
        after = function(plugin)
            require("CopilotChat").setup({
                window = {
                    layout = "float",
                    width = 120,        -- Fixed width in columns
                    height = 30,        -- Fixed height in rows
                    border = "rounded", -- 'single', 'double', 'rounded', 'solid'
                    title = "🤖 AI Assistant",
                    zindex = 100,       -- Ensure window stays on top
                },

                headers = {
                    user = "👤 You: ",
                    assistant = "🤖 Copilot: ",
                    tool = "🔧 Tool: ",
                },
                separator = "━━",
                show_folds = false,
                selection = function(source)
                    return require("CopilotChat.select").visual(source) or require("CopilotChat.select").line(source)
                end,
            })
        end,
    },
    {
        "nvim-highlight-colors",
        enabled = (nixCats("reactjs") and not vscode) or false,
        event = "DeferredUIEnter",
        after = function(plugin)
            require("nvim-highlight-colors").setup({
                render = "background",
            })
        end,
    },
    {
        "hlchunk.nvim",
        enabled = (nixCats("general") and not vscode) or false,
        event = "DeferredUIEnter",
        after = function(plugin)
            require("hlchunk").setup({
                chunk = { enable = true },
                line_num = { enable = true },
            })
        end,
    },
    {
        "easy-dotnet.nvim",
        enabled = (nixCats("csharp") and not vscode) or false,
        event = "LspAttach",
        after = function(plugin)
            require("easy-dotnet").setup()
        end,
    },
    {
        "neotest",
        enabled = nixCats("reactjs") or nixCats("csharp") or false,
        event = "DeferredUIEnter",
        load = function(name)
            vim.cmd.packadd(name)
            if nixCats("reactjs") then
                vim.cmd.packadd("neotest-vitest")
            end
            if nixCats("csharp") then
                vim.cmd.packadd("neotest-dotnet")
            end
        end,
        after = function(plugin)
            require("neotest").setup({
                adapters = {
                    nixCats("reactjs") and require("neotest-vitest") or nil,
                    nixCats("csharp") and require("neotest-dotnet")({
                        dap = { justMyCode = false },
                    }) or nil,
                },
            })
            map("n", "<Leader>tn", "<Cmd>lua require('neotest').run.run()<CR>", { desc = "Run nearest test" })
            map(
                "n",
                "<Leader>tf",
                "<Cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>",
                { desc = "Run test file" }
            )
            map("n", "<Leader>tl", "<Cmd>lua require('neotest').run.run_last()<CR>", { desc = "Run last test" })
            map(
                "n",
                "<Leader>td",
                "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>",
                { desc = "Debug nearest test" }
            )
            map("n", "<Leader>ts", "<Cmd>lua require('neotest').summary.toggle()<CR>", { desc = "Toggle test summary" })
            map("n", "<Leader>to", "<Cmd>lua require('neotest').output.open()<CR>", { desc = "Show test output" })
            map(
                "n",
                "<Leader>tp",
                "<Cmd>lua require('neotest').output_panel.toggle()<CR>",
                { desc = "Toggle output panel" }
            )
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
        enabled = nixCats("general") or nixCats("miniNvim") or false,
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
        lsp = {
            filetypes = {
                "graphql",
            }
        },
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
