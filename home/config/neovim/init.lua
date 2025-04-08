local vim = vim
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
vim.o.winborder = "solid"
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
    { "<leader>r", group = "run" },
    { "<leader>w", proxy = "<c-w>", group = "windows" },
    { "<leader>b", group = "buffers", expand = function() return require("which-key.extras").expand.buf() end },
})

require("nvim-treesitter.configs").setup({
    highlight = { enable = true },
})

require("gitsigns").setup()

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

require("Snacks").setup({
    animate = { enabled = true },
    dim = { enabled = true },
    image = { enabled = true },
    notifier = { enabled = true },
    rename = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    picker = { enabled = true },
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
        require("neotest-dotnet"),
    },
})

require("tiny-inline-diagnostic").setup({
    multilines = true,
    break_line = { enabled = true },
})

require("roslyn").setup({
    exe = "Microsoft.CodeAnalysis.LanguageServer",
})

-- configure overseer
require("overseer").setup()
vim.keymap.set("n", "<Leader>rr", "<Cmd>OverseerRun<cr>", { desc = "Run task" })
vim.keymap.set("n", "<Leader>rv", "<Cmd>OverseerToggle<cr>", { desc = "View running task" })

-- configure dap



vim.g.mapleader = " "
vim.keymap.set("n", "<Leader>bd", "<Cmd>lua MiniBufremove.delete()<cr>", { desc = "Delete" })
vim.keymap.set("n", "<Leader>e", "<Cmd>Yazi<cr>", { desc = "Explorer" })
vim.keymap.set("n", "<Leader>cr", "<Cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
vim.keymap.set("n", "<Leader>cf", "<Cmd>lua vim.lsp.buf.format()<cr>", { desc = "Format buffer" })
vim.keymap.set("n", "<Leader>ca", "<Cmd>lua require('actions-preview').code_actions()<cr>", { desc = "Code actions" })

-- Smart mappings
vim.keymap.set("n", "<leader><space>", "<Cmd>lua Snacks.picker.smart()<cr>", { desc = "Smart Find Files" })
vim.keymap.set("n", "<leader>,", "<Cmd>lua Snacks.picker.buffers()<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", "<Cmd>lua Snacks.picker.lines()<cr>", { desc = "Buffer Lines" })
vim.keymap.set("n", "<leader>:", "<Cmd>lua Snacks.picker.command_history()<cr>", { desc = "Command History" })
vim.keymap.set("n", "<leader>n", "<Cmd>lua Snacks.picker.notifications()<cr>", { desc = "Notification History" })

-- Buffer mappings
vim.keymap.set("n", "<leader>bl", "<Cmd>lua Snacks.picker.buffers()<cr>", { desc = "Buffer list" })

-- Find mappings
vim.keymap.set("n", "<leader>ff", "<Cmd>lua Snacks.picker.files()<cr>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", "<Cmd>lua Snacks.picker.git_files()<cr>", { desc = "Find Git Files" })
vim.keymap.set("n", "<leader>fp", "<Cmd>lua Snacks.picker.projects()<cr>", { desc = "Projects" })
vim.keymap.set("n", "<leader>fr", "<Cmd>lua Snacks.picker.recent()<cr>", { desc = "Recent" })

-- Git mappings
vim.keymap.set("n", "<leader>gb", "<Cmd>lua Snacks.picker.git_branches()<cr>", { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gl", "<Cmd>lua Snacks.picker.git_log()<cr>", { desc = "Git Log" })
vim.keymap.set("n", "<leader>gL", "<Cmd>lua Snacks.picker.git_log_line()<cr>", { desc = "Git Log Line" })
vim.keymap.set("n", "<leader>gs", "<Cmd>lua Snacks.picker.git_status()<cr>", { desc = "Git Status" })
vim.keymap.set("n", "<leader>gS", "<Cmd>lua Snacks.picker.git_stash()<cr>", { desc = "Git Stash" })
vim.keymap.set("n", "<leader>gd", "<Cmd>lua Snacks.picker.git_diff()<cr>", { desc = "Git Diff (Hunks)" })
vim.keymap.set("n", "<leader>gf", "<Cmd>lua Snacks.picker.git_log_file()<cr>", { desc = "Git Log File" })

-- Grep mappings
vim.keymap.set("n", "<leader>sb", "<Cmd>lua Snacks.picker.lines()<cr>", { desc = "Buffer Lines" })
vim.keymap.set("n", "<leader>sB", "<Cmd>lua Snacks.picker.grep_buffers()<cr>", { desc = "Grep Open Buffers" })
vim.keymap.set("n", "<leader>sg", "<Cmd>lua Snacks.picker.grep()<cr>", { desc = "Grep" })
vim.keymap.set({ "n", "x" }, "<leader>sw", "<Cmd>lua Snacks.picker.grep_word()<cr>", { desc = "Visual selection or word" })

-- Search mappings
vim.keymap.set("n", '<leader>s"', "<Cmd>lua Snacks.picker.registers()<cr>", { desc = "Registers" })
vim.keymap.set("n", "<leader>s/", "<Cmd>lua Snacks.picker.search_history()<cr>", { desc = "Search History" })
vim.keymap.set("n", "<leader>sa", "<Cmd>lua Snacks.picker.autocmds()<cr>", { desc = "Autocmds" })
vim.keymap.set("n", "<leader>sc", "<Cmd>lua Snacks.picker.command_history()<cr>", { desc = "Command History" })
vim.keymap.set("n", "<leader>sC", "<Cmd>lua Snacks.picker.commands()<cr>", { desc = "Commands" })
vim.keymap.set("n", "<leader>sd", "<Cmd>lua Snacks.picker.diagnostics()<cr>", { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>sD", "<Cmd>lua Snacks.picker.diagnostics_buffer()<cr>", { desc = "Buffer Diagnostics" })
vim.keymap.set("n", "<leader>sh", "<Cmd>lua Snacks.picker.help()<cr>", { desc = "Help Pages" })
vim.keymap.set("n", "<leader>sH", "<Cmd>lua Snacks.picker.highlights()<cr>", { desc = "Highlights" })
vim.keymap.set("n", "<leader>si", "<Cmd>lua Snacks.picker.icons()<cr>", { desc = "Icons" })
vim.keymap.set("n", "<leader>sj", "<Cmd>lua Snacks.picker.jumps()<cr>", { desc = "Jumps" })
vim.keymap.set("n", "<leader>sk", "<Cmd>lua Snacks.picker.keymaps()<cr>", { desc = "Keymaps" })
vim.keymap.set("n", "<leader>sl", "<Cmd>lua Snacks.picker.loclist()<cr>", { desc = "Location List" })
vim.keymap.set("n", "<leader>sm", "<Cmd>lua Snacks.picker.marks()<cr>", { desc = "Marks" })
vim.keymap.set("n", "<leader>sM", "<Cmd>lua Snacks.picker.man()<cr>", { desc = "Man Pages" })
vim.keymap.set("n", "<leader>sq", "<Cmd>lua Snacks.picker.qflist()<cr>", { desc = "Quickfix List" })
vim.keymap.set("n", "<leader>sR", "<Cmd>lua Snacks.picker.resume()<cr>", { desc = "Resume" })
vim.keymap.set("n", "<leader>su", "<Cmd>lua Snacks.picker.undo()<cr>", { desc = "Undo History" })
vim.keymap.set("n", "<leader>uC", "<Cmd>lua Snacks.picker.colorschemes()<cr>", { desc = "Colorschemes" })

-- LSP mappings
vim.keymap.set("n", "gd", "<Cmd>lua Snacks.picker.lsp_definitions()<cr>", { desc = "Goto Definition" })
vim.keymap.set("n", "gD", "<Cmd>lua Snacks.picker.lsp_declarations()<cr>", { desc = "Goto Declaration" })
vim.keymap.set("n", "gr", "<Cmd>lua Snacks.picker.lsp_references()<cr>", { desc = "References", nowait = true })
vim.keymap.set("n", "gI", "<Cmd>lua Snacks.picker.lsp_implementations()<cr>", { desc = "Goto Implementation" })
vim.keymap.set("n", "gy", "<Cmd>lua Snacks.picker.lsp_type_definitions()<cr>", { desc = "Goto T[y]pe Definition" })
vim.keymap.set("n", "<leader>ss", "<Cmd>lua Snacks.picker.lsp_symbols()<cr>", { desc = "LSP Symbols" })
vim.keymap.set("n", "<leader>sS", "<Cmd>lua Snacks.picker.lsp_workspace_symbols()<cr>", { desc = "LSP Workspace Symbols" })
vim.keymap.set("n", "<leader>z", "<Cmd>lua Snacks.picker.zoxide()<cr>", { desc = "Zoxide projects" })
