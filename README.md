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


## Config options
### Keybinds

You can configure keybinds with the `keys` key sibling to `config` like so
```lua
keys = {
  { "<leader>fd", ":SmartGoToDefinition<CR>", desc = "[F]ind [d]efinition" },
},
```

## Commands

Here are the available commands:
- :SmartGoToDefinition, which looks in all available caches for the item under the cursor
