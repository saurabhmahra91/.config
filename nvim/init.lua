-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)


vim.keymap.set('i', 'ii', '<Esc>')
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.wrap = false
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.scrolloff = 1
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.title = true
vim.opt.titlestring = "nv - %t"



-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- add your plugins here
        {
            "echasnovski/mini.icons",
            version = false,
            config = function()
                require("mini.icons").setup({
                    style = "ascii",
                })

                MiniIcons.mock_nvim_web_devicons()
            end,

        },
        {
            'stevearc/oil.nvim',
            opts = {},
            dependencies = { "echasnovski/mini.icons" },
            keys = {
                {"-", "<CMD>Oil<CR>", desc = "Open parent directory"},
            },
        },
        {
            "nvim-tree/nvim-tree.lua",
            version = "*",
            lazy = false,
            dependencies = {
                "echasnovski/mini.icons",
            },
            config = function()
                require("nvim-tree").setup({
                    sort = {
                        sorter = "case_sensitive",
                    },
                    view = {
                        width = 30,
                    },
                    renderer = {
                        group_empty = true,
                        icons = {
                            show = {
                                file = false,
                                folder = false,
                                folder_arrow = true,
                                git = true,
                            },
                            glyphs = {
                                default = "",
                                symlink = "",
                                folder = {
                                    arrow_closed = "▸",
                                    arrow_open = "▾",
                                },
                                git = {
                                    unstaged = "○",
                                    staged = "✓",
                                    unmerged = "",
                                    renamed = "➜",
                                    untracked = "⊕",
                                    deleted = "✖",
                                    ignored = "◌",
                                },
                            },
                        },
                    },
                    filters = {
                        dotfiles = false,
                    },
                })

                -- Open nvim-tree automatically on startup if no file is specified
                local function open_nvim_tree(data)
                    -- buffer is a directory
                    local directory = vim.fn.isdirectory(data.file) == 1

                    if not directory then
                        return
                    end

                    -- change to the directory
                    vim.cmd.cd(data.file)

                    -- open the tree
                    require("nvim-tree.api").tree.open()
                end

                vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
            end,
        },
        {
            "nvim-treesitter/nvim-treesitter",
            branch = "main",
            lazy = false,
            build = ":TSUpdate",
            config = function()
                local parsers = {
                    "lua", "vim", "vimdoc", "python", "javascript",
                    "typescript", "tsx", "json", "yaml", "toml", "bash",
                    "markdown", "markdown_inline", "go", "rust", "c",
                    "cpp", "html", "css", "sql",
                }

                local installed = require("nvim-treesitter.config").get_installed()
                local missing = vim.tbl_filter(function(parser)
                    return not vim.tbl_contains(installed, parser)
                end, parsers)
                if #missing > 0 then
                    require("nvim-treesitter").install(missing)
                end

                vim.api.nvim_create_autocmd("FileType", {
                    callback = function(args)
                        local ok = pcall(vim.treesitter.start, args.buf)
                        if ok then
                            vim.bo[args.buf].indentexpr =
                                "v:lua.require'nvim-treesitter'.indentexpr()"
                        end
                    end,
                })
            end,
        },
        {
            "neovim/nvim-lspconfig",
            dependencies = {
                { "mason-org/mason.nvim", opts = {} },
                "mason-org/mason-lspconfig.nvim",
                "b0o/schemastore.nvim",
            },
            config = function()
                require("lsp").setup()
            end,
        },
        {
            "lukas-reineke/indent-blankline.nvim",
            main = "ibl",
            opts = {
                indent = { char = "▏" },
                scope = {
                    enabled = true,
                    show_start = false,
                    show_end = false,
                },
            },
        },
        {
            "OXY2DEV/markview.nvim",
            lazy = false,

            -- Completion for `blink.cmp`
            -- dependencies = { "saghen/blink.cmp" },
        },
        {
            "lewis6991/gitsigns.nvim",
            signs = {
                add          = { text = '┃' },
                change       = { text = '┃' },
                delete       = { text = '_' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
                untracked    = { text = '┆' },
            },
            signs_staged = {
                add          = { text = '┃' },
                change       = { text = '┃' },
                delete       = { text = '_' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
                untracked    = { text = '┆' },
            },
            signs_staged_enable = true,
            signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
            numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
            linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
            word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
            watch_gitdir = {
                follow_files = true
            },
            auto_attach = true,
            attach_to_untracked = false,
            current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                delay = 1000,
                ignore_whitespace = false,
                virt_text_priority = 100,
                use_focus = true,
            },
            current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
            blame_formatter = nil, -- Use default
            sign_priority = 6,
            update_debounce = 100,
            status_formatter = nil, -- Use default
            max_file_length = 10000, -- Disable if file is longer than this (in lines)
            preview_config = {
                -- Options passed to nvim_open_win
                style = 'minimal',
                relative = 'cursor',
                row = 0,
                col = 1
            },
        },
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "monokai" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})

vim.cmd.colorscheme("monokai")

