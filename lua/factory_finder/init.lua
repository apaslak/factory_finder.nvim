local M = {}
local factory_finder = require('factory_finder.factory')

local default_config = {
  suppress_notifications = false,
}

M.config = {}

function M.setup(user_config)
  M.config = vim.tbl_extend("force", default_config, user_config or {})

  factory_finder.extend_treesitter()

  vim.print('prepped the queries')
end

vim.api.nvim_create_user_command('IsFactoryFunction', function() factory_finder.identify_factory_name() end, {})

return M
