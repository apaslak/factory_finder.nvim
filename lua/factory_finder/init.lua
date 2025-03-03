local M = {}
local factory_finder = require('factory_finder.factory')
local shared_example_finder = require('factory_finder.shared_example')
local shared_context_finder = require('factory_finder.shared_context')

local default_config = {
  suppress_notifications = false,
}

M.config = {}

function M.setup(user_config)
  M.config = vim.tbl_extend("force", default_config, user_config or {})

  factory_finder.extend_treesitter()
  shared_example_finder.extend_treesitter()
  shared_context_finder.extend_treesitter()

  vim.print('prepped the queries')
end

vim.api.nvim_create_user_command('IsFactoryFunction', function() factory_finder.identify_factory_name() end, {})
vim.api.nvim_create_user_command('IsSharedExample', function() shared_example_finder.identify_shared_example_name() end, {})
vim.api.nvim_create_user_command('IsSharedContext', function() shared_context_finder.identify_shared_context_name() end, {})

return M
