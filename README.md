# Factory Finder
This plugin aims to add "go to definition" support for [FactoryBot](https://github.com/thoughtbot/factory_bot) factory definitions.

## Installation

With lazy package manager,
```lua
{
  "apaslak/factory_finder.nvim",
  config = function()
    require("factory_finder")
  end,
  event = "VeryLazy",
}
```
## Notes and assumptions
- When you open neovim for the first time, it will populate the "caches" and be slow. Every time after that, it should not impact performance.
- This plugin requires ripgrep.
- This plugin writes files into the `~/.dotfiles/factory_dinder/` directory, but doesn't create it for you.


## Config options
### Notifications
If the notifications seem noisy, you can suppress them with
```lua
config = function()
  require("factory_finder").setup({
    suppress_notifications = true
  })
end
```
### Keybinds

You can configure keybinds with the `keys` key sibling to `config` like so
```lua
keys = {
  { "<leader>gd", ":SmartGoToDefinition<CR>", desc = "[G]o to [d]efinition" },
  { "<leader>rc", ":RefreshCaches<CR>", desc = "[R]efresh [c]aches" },
  { "<leader>ic", ":InspectCaches<CR>", desc = "[I]nspect [c]aches" },
},
```
I don't have good keybind suggestions for you here because I hooked into the `gd` LSP go to definition keybind, which is explained below.

## Commands

Here are the available commands:
- :SmartGoToDefinition, which looks in all available caches for the item under the cursor
- :RefreshCaches, which refreshes the caches for all items
- :InspectCaches, which inspects the caches by putting the contents in a notification.

- :FactoryGoToDefinition, which triggers the "go to definition" for any factory on the line under the cursor
- :RefreshFactoryCache, which triggers a refresh of the factory cache
- :InspectFactoryCache, which triggers a notification of the factory cache for inspection

- :SharedExampleGoToDefinition, which triggers the "go to definition" for a shared_example on the line under the cursor
- :RefreshSharedExampleCache, which triggers a refresh of the shared_example cache
- :InspectSharedExampleCache, which triggers a notification of the shared_example cache for inspection

## Hooking into LSP 'go to definition'

I've added the following code to the `lua/plugins/lsp/go_to.lua` file:
```lua
local M = {}

function M.definition()
  local params = vim.lsp.util.make_position_params()
  local results = vim.lsp.buf_request_sync(0, 'textDocument/definition', params, 1000)

  if results then
    for _, res in pairs(results) do
      if res.result and not vim.tbl_isempty(res.result) then
        local location = res.result[1]
        if location then
          vim.lsp.util.jump_to_location(location)
          return
        end
      end
    end
  end

  vim.cmd("SmartGoToDefinition")
end

return M
```

Then, the `on_attach` function for the LSP keybinds looks like this:
```lua
vim.keymap.set('n', 'gd', '<cmd>lua require("plugins.lsp.go_to").definition()<cr><cmd>norm zz<cr>', opts)
```
