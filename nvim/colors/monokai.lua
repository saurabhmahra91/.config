-- Monokai colorscheme loader. Activate with `:colorscheme monokai`.
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "monokai"

local palette = require("monokai.palette")
local groups = require("monokai.highlights")(palette)

for name, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, name, opts)
end
