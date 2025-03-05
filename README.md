# Factory Finder
This plugin aims to add "go to definition" support for:
- [FactoryBot](https://github.com/thoughtbot/factory_bot) factory definitions.
- [RSpec shared_examples](https://rspec.info/features/3-12/rspec-core/example-groups/shared-examples/)
- [RSpec shared_context](https://rspec.info/features/3-12/rspec-core/example-groups/shared-context/)

## Installation

With lazy package manager,
```lua
{
  "apaslak/factory_finder.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    require("factory_finder")
  end
}
```
## Notes and assumptions
- When you open neovim for the first time, it will populate the "caches" and be slow. Every time after that, it should not impact performance.
- This plugin requires ripgrep.
- This plugin was designed for a large mono repo using [Packwerk](https://github.com/Shopify/packwerk) such that the file location of these definitions is less straight forward.


## Config options
### Keybinds

You can configure keybinds with the `keys` key sibling to `config` like so
```lua
keys = {
  { "<leader>fd", ":SmartGoToDefinition<CR>", desc = "[F]ind [d]efinition" },
  { "<leader>rc", ":RefreshCaches<CR>", desc = "[R]efresh [C]aches" },
},
```
NOTE: See below for how I hook into the `gd` keybind for a more seamless integration.

## Commands

Here are the available commands:
- :SmartGoToDefinition, which looks in all available caches for the item under the cursor
- :RefreshCaches, which will refresh all the caches to pull in changed definitions

## Hooking into LSP 'go to definition'

I've added the following code to the `lua/plugins/lsp/go_to.lua` file:

```lua
local M = {}

function M.definition()
  if require('factory_finder').go_to_definition() then
    return
  else
    vim.lsp.buf.definition()
  end
end

return M
```

Then, the `on_attach` function for the LSP keybinds looks like this:

```lua
vim.keymap.set('n', 'gd', '<cmd>lua require("plugins.lsp.go_to").definition()<cr>', opts)
```
