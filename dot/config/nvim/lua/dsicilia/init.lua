-- Speeds up loading time by enabling the experimental Lua module
-- loader which removes the default Neovim loader and uses the
-- byte-compilation cache.
vim.loader.enable()

-- Should go first.
require'dsicilia.packages'

require'dsicilia.autocmds'
require'dsicilia.colors'
require'dsicilia.dev'
require'dsicilia.folding'
require'dsicilia.format'
require'dsicilia.keymap'
require'dsicilia.lsp'
require'dsicilia.messages'
require'dsicilia.options'
require'dsicilia.filetypes'
require'dsicilia.resize'
require'dsicilia.rn'
require'dsicilia.search'
require'dsicilia.status-bar'
