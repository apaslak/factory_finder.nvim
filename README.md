# Factory Finder
This plugin aims to add "go to definition" support for [FactoryBot](https://github.com/thoughtbot/factory_bot) factory definitions.

## Installation
NOTE: This plugin requires ripgrep.

With lazy package manager,
```lua
{
  "apaslak/factory_finder.nvim",
  config = function()
    require("factory_finder")
  end,
  lazy = false, # importing for loading the cache when nvim starts
}
```

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
  { "<leader>fb", ":FindFactory<CR>", desc = "[F]ind Factory[B]ot Definition" },
  { "<leader>rc", ":RefreshFactoryCache<CR>", desc = "[R]efresh FactoryBot [c]ache" },
  { "<leader>ic", ":InspectFactoryCache<CR>", desc = "[I]nspect FactoryBot [c]ache" },
},
```

## Commands

There are 3 commands available:
- :FindFactory, which triggers the "go to definition" for any factory on the line under the cursor
- :RefreshFactoryCache, which triggers a refresh of the factory cache
- :InspectFactoryCache, which triggers a notification of the factory cache for inspection

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

  vim.cmd("FindFactory")
end

return M
```

Then, the `on_attach` function for the LSP keybinds looks like this:
```lua
vim.keymap.set('n', 'gd', '<cmd>lua require("plugins.lsp.go_to").definition()<cr><cmd>norm zz<cr>', opts)
```
