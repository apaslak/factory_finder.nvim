local M = {}
local factory_finder = require('factory_finder.factory')
local shared_example_finder = require('factory_finder.shared_example')
local shared_context_finder = require('factory_finder.shared_context')

local default_config = {}

M.config = {}

local function init_plugin_directory()
  local cache_dir = vim.fn.stdpath('cache') .. '/factory_finder/'

  if not vim.loop.fs_stat(cache_dir) then
    vim.loop.fs_mkdir(cache_dir, 493) -- 493 is the octal permission 0755
  end
end

function M.setup(user_config)
  M.config = vim.tbl_extend("force", default_config, user_config or {})
  init_plugin_directory()

  factory_finder.extend_treesitter()
  shared_example_finder.extend_treesitter()
  shared_context_finder.extend_treesitter()

  factory_finder.load_cache()
  -- shared_example_finder.load_cache()
  -- shared_context_finder.load_cache()
end

local function go_to_definition()
  if factory_finder.go_to_definition() then
    return
  end
  if shared_example_finder.go_to_definition() then
    return
  end
  if shared_context_finder.go_to_definition() then
    return
  end
end

vim.api.nvim_create_user_command('SmartGoToDefinition', function() go_to_definition() end, {})
vim.api.nvim_create_user_command('RefreshCache', function() factory_finder.refresh_cache() end, {})
vim.api.nvim_create_user_command('InspectCache', function() factory_finder.inspect_cache() end, {})
-- vim.api.nvim_create_user_command('IsSharedExample', function() shared_example_finder.identify_shared_example_name() end, {})
-- vim.api.nvim_create_user_command('IsSharedContext', function() shared_context_finder.identify_shared_context_name() end, {})

return M
