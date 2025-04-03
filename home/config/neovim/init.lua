local vim = vim
vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.hlsearch = false
vim.o.winborder = "solid"
vim.o.laststatus = 3
vim.o.statusline = " %f %m %= %l:%c ✽ [%{mode()}] "

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
    virtual_lines = { current_line = true },
})

vim.g.mapleader = " "
vim.keymap.set("n", "<Leader>bd", "<Cmd>lua MiniBufremove.delete()<cr>", { desc = "Delete" })
vim.keymap.set("n", "<Leader>e", "<Cmd>lua Snacks.explorer()<cr>", { desc = "Explorer" })
vim.keymap.set("n", "<Leader>cr", "<Cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
vim.keymap.set("n", "<Leader>cf", "<Cmd>lua vim.lsp.buf.format()<cr>", { desc = "Format buffer" })
vim.keymap.set("n", "<Leader>gg", "<Cmd>Neogit<cr>", { desc = "Neogit" })
vim.keymap.set("n", "<Leader>ca", "<Cmd>lua require('actions-preview').code_actions()<cr>", { desc = "Code actions" })

if vim.g.vscode then
    return
end

require("mini.basics").setup()
require("mini.bufremove").setup()
require("mini.extra").setup()
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

require("rose-pine").setup({
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
    { "g",         group = "goto" },
    { "<leader>w", proxy = "<c-w>", group = "windows" },
    {
        "<leader>b",
        group = "buffers",
        expand = function()
            return require("which-key.extras").expand.buf()
        end,
    },
    {
        "<leader><space>",
        function()
            Snacks.picker.smart()
        end,
        desc = "Smart Find Files",
    },
    {
        "<leader>,",
        function()
            Snacks.picker.buffers()
        end,
        desc = "Buffers",
    },
    {
        "<leader>/",
        function()
            Snacks.picker.grep()
        end,
        desc = "Grep",
    },
    {
        "<leader>:",
        function()
            Snacks.picker.command_history()
        end,
        desc = "Command History",
    },
    {
        "<leader>n",
        function()
            Snacks.picker.notifications()
        end,
        desc = "Notification History",
    },
    {
        "<leader>e",
        function()
            Snacks.explorer()
        end,
        desc = "File Explorer",
    },
    -- find
    {
        "<leader>fb",
        function()
            Snacks.picker.buffers()
        end,
        desc = "Buffers",
    },
    {
        "<leader>fc",
        function()
            Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
        end,
        desc = "Find Config File",
    },
    {
        "<leader>ff",
        function()
            Snacks.picker.files()
        end,
        desc = "Find Files",
    },
    {
        "<leader>fg",
        function()
            Snacks.picker.git_files()
        end,
        desc = "Find Git Files",
    },
    {
        "<leader>fp",
        function()
            Snacks.picker.projects()
        end,
        desc = "Projects",
    },
    {
        "<leader>fr",
        function()
            Snacks.picker.recent()
        end,
        desc = "Recent",
    },
    -- git
    {
        "<leader>gb",
        function()
            Snacks.picker.git_branches()
        end,
        desc = "Git Branches",
    },
    {
        "<leader>gl",
        function()
            Snacks.picker.git_log()
        end,
        desc = "Git Log",
    },
    {
        "<leader>gL",
        function()
            Snacks.picker.git_log_line()
        end,
        desc = "Git Log Line",
    },
    {
        "<leader>gs",
        function()
            Snacks.picker.git_status()
        end,
        desc = "Git Status",
    },
    {
        "<leader>gS",
        function()
            Snacks.picker.git_stash()
        end,
        desc = "Git Stash",
    },
    {
        "<leader>gd",
        function()
            Snacks.picker.git_diff()
        end,
        desc = "Git Diff (Hunks)",
    },
    {
        "<leader>gf",
        function()
            Snacks.picker.git_log_file()
        end,
        desc = "Git Log File",
    },
    -- Grep
    {
        "<leader>sb",
        function()
            Snacks.picker.lines()
        end,
        desc = "Buffer Lines",
    },
    {
        "<leader>sB",
        function()
            Snacks.picker.grep_buffers()
        end,
        desc = "Grep Open Buffers",
    },
    {
        "<leader>sg",
        function()
            Snacks.picker.grep()
        end,
        desc = "Grep",
    },
    {
        "<leader>sw",
        function()
            Snacks.picker.grep_word()
        end,
        desc = "Visual selection or word",
        mode = { "n", "x" },
    },
    -- search
    {
        '<leader>s"',
        function()
            Snacks.picker.registers()
        end,
        desc = "Registers",
    },
    {
        "<leader>s/",
        function()
            Snacks.picker.search_history()
        end,
        desc = "Search History",
    },
    {
        "<leader>sa",
        function()
            Snacks.picker.autocmds()
        end,
        desc = "Autocmds",
    },
    {
        "<leader>sb",
        function()
            Snacks.picker.lines()
        end,
        desc = "Buffer Lines",
    },
    {
        "<leader>sc",
        function()
            Snacks.picker.command_history()
        end,
        desc = "Command History",
    },
    {
        "<leader>sC",
        function()
            Snacks.picker.commands()
        end,
        desc = "Commands",
    },
    {
        "<leader>sd",
        function()
            Snacks.picker.diagnostics()
        end,
        desc = "Diagnostics",
    },
    {
        "<leader>sD",
        function()
            Snacks.picker.diagnostics_buffer()
        end,
        desc = "Buffer Diagnostics",
    },
    {
        "<leader>sh",
        function()
            Snacks.picker.help()
        end,
        desc = "Help Pages",
    },
    {
        "<leader>sH",
        function()
            Snacks.picker.highlights()
        end,
        desc = "Highlights",
    },
    {
        "<leader>si",
        function()
            Snacks.picker.icons()
        end,
        desc = "Icons",
    },
    {
        "<leader>sj",
        function()
            Snacks.picker.jumps()
        end,
        desc = "Jumps",
    },
    {
        "<leader>sk",
        function()
            Snacks.picker.keymaps()
        end,
        desc = "Keymaps",
    },
    {
        "<leader>sl",
        function()
            Snacks.picker.loclist()
        end,
        desc = "Location List",
    },
    {
        "<leader>sm",
        function()
            Snacks.picker.marks()
        end,
        desc = "Marks",
    },
    {
        "<leader>sM",
        function()
            Snacks.picker.man()
        end,
        desc = "Man Pages",
    },
    {
        "<leader>sp",
        function()
            Snacks.picker.lazy()
        end,
        desc = "Search for Plugin Spec",
    },
    {
        "<leader>sq",
        function()
            Snacks.picker.qflist()
        end,
        desc = "Quickfix List",
    },
    {
        "<leader>sR",
        function()
            Snacks.picker.resume()
        end,
        desc = "Resume",
    },
    {
        "<leader>su",
        function()
            Snacks.picker.undo()
        end,
        desc = "Undo History",
    },
    {
        "<leader>uC",
        function()
            Snacks.picker.colorschemes()
        end,
        desc = "Colorschemes",
    },
    -- LSP
    {
        "gd",
        function()
            Snacks.picker.lsp_definitions()
        end,
        desc = "Goto Definition",
    },
    {
        "gD",
        function()
            Snacks.picker.lsp_declarations()
        end,
        desc = "Goto Declaration",
    },
    {
        "gr",
        function()
            Snacks.picker.lsp_references()
        end,
        nowait = true,
        desc = "References",
    },
    {
        "gI",
        function()
            Snacks.picker.lsp_implementations()
        end,
        desc = "Goto Implementation",
    },
    {
        "gy",
        function()
            Snacks.picker.lsp_type_definitions()
        end,
        desc = "Goto T[y]pe Definition",
    },
    {
        "<leader>ss",
        function()
            Snacks.picker.lsp_symbols()
        end,
        desc = "LSP Symbols",
    },
    {
        "<leader>sS",
        function()
            Snacks.picker.lsp_workspace_symbols()
        end,
        desc = "LSP Workspace Symbols",
    },
    {
        "<leader>z",
        function()
            Snacks.picker.zoxide()
        end,
        desc = "Zoxide projects",
    },
})

require("nvim-treesitter.configs").setup({
    highlight = { enable = true },
})

require("gitsigns").setup()

local capabilities = require("blink.cmp").get_lsp_capabilities()
local lspconfig = require("lspconfig")
lspconfig.csharp_ls.setup({ capabilities = capabilities })
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

require("Snacks").setup({
    animate = { enabled = true },
    dim = { enabled = true },
    explorer = { enabled = true },
    image = { enabled = true },
    notifier = { enabled = true },
    rename = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    picker = { enabled = true, sources = { explorer = { layout = { layout = { position = "right" } } } } },
})

require("neogit").setup({ graph_style = "kitty" })

require("typescript-tools").setup({})

require("tsc").setup()

require("actions-preview").setup({
    highlight_command = {
        require("actions-preview.highlight").delta(),
    },
    backend = { "snacks", "nui" },
    snacks = {
        layout = {
            preset = "vertical",
            layout = {
                border = "solid",
            },
        },
    },
})

require("neotest").setup({
    adapters = {
        require("neotest-vitest"),
    },
})
