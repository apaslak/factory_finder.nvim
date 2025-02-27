local M = {}

local default_config = {
  suppress_notifications = false,
}

M.config = {}

local utils = require('factory_finder.utils')
local factory_finder = require('factory_finder.factory')

function M.setup(user_config)
  M.config = vim.tbl_extend("force", default_config, user_config or {})

  factory_finder.load_cache(M.config)
end

vim.api.nvim_create_user_command("FindFactory", factory_finder.go_to_factory_definition, { nargs = 0, desc = "Find FactoryBot definition" })
vim.api.nvim_create_user_command("RefreshFactoryCache", factory_finder.refresh_cache, { nargs = 0, desc = "Refresh FactoryBot cache" })
vim.api.nvim_create_user_command("InspectFactoryCache", factory_finder.inspect_cache, { nargs = 0, desc = "Inspect FactoryBot cache" })

return M
