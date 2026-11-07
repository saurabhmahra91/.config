-- LSP setup: server list, per-server tuning, diagnostics, buffer keymaps.
-- Servers are installed by mason and enabled by mason-lspconfig (Neovim 0.11+
-- auto-enable via vim.lsp.enable). Per-server overrides go through
-- vim.lsp.config and must run before mason-lspconfig.setup().
local M = {}

local SERVERS = {
    "basedpyright", -- Python types / hover / goto
    "ruff",         -- Python lint + format (Rust)
    "rust_analyzer",
    "vtsls",        -- JS / TS
    "clangd",       -- C / C++
    "bashls",
    "yamlls",
    "sqls",         -- SQL (connects to Postgres for schema completion)
}

local function _configure_yamlls()
    vim.lsp.config("yamlls", {
        settings = {
            yaml = {
                schemaStore = { enable = false, url = "" },
                schemas = require("schemastore").yaml.schemas(),
                validate = true,
                format = { enable = true },
                keyOrdering = false,
            },
        },
    })
end

local function _configure_python()
    vim.lsp.config("basedpyright", {
        settings = {
            basedpyright = {
                analysis = {
                    typeCheckingMode = "standard",
                    diagnosticMode = "openFilesOnly",
                },
            },
        },
    })
    vim.lsp.config("ruff", {
        on_attach = function(client)
            client.server_capabilities.hoverProvider = false
        end,
    })
end

local function _configure_servers()
    _configure_yamlls()
    _configure_python()
end

local function _configure_diagnostics()
    vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded" },
    })
end

local function _buffer_keymaps(event)
    local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Goto definition")
    map("gD", vim.lsp.buf.declaration, "Goto declaration")
    map("<leader>f", function()
        vim.lsp.buf.format({ async = true })
    end, "Format buffer")
end

local function _register_keymaps()
    vim.api.nvim_create_autocmd("LspAttach", { callback = _buffer_keymaps })
end

function M.setup()
    _configure_servers()
    _configure_diagnostics()
    _register_keymaps()
    require("mason-lspconfig").setup({ ensure_installed = SERVERS })
end

return M
