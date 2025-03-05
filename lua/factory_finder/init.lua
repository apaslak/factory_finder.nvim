local M = {}
local utils = require('factory_finder.utils')
local file_utils = require('factory_finder.file_utils')
local factory_finder = require('factory_finder.factory')
local shared_example_finder = require('factory_finder.shared_example')
local shared_context_finder = require('factory_finder.shared_context')

local default_config = {}

M.config = {}

function M.setup(user_config)
  local project_root = utils.find_project_root()
  if not project_root then
    return
  end

  file_utils.get_or_create_repo_dir(project_root)
  M.config = vim.tbl_extend("force", default_config, user_config or {})

  factory_finder.extend_treesitter()
  shared_example_finder.extend_treesitter()
  shared_context_finder.extend_treesitter()

  factory_finder.load_cache()
  shared_example_finder.load_cache()
  shared_context_finder.load_cache()
end

function M.refresh_caches()
  factory_finder.refresh_cache()
  shared_example_finder.refresh_cache()
  shared_context_finder.refresh_cache()
end

function M.go_to_definition()
  if factory_finder.go_to_definition() then
    return true
  end
  if shared_example_finder.go_to_definition() then
    return true
  end
  if shared_context_finder.go_to_definition() then
    return true
  end

  return false
end

vim.api.nvim_create_user_command('SmartGoToDefinition', function() M.go_to_definition() end, {})
vim.api.nvim_create_user_command('RefreshCaches', function() M.refresh_caches() end, {})

return M
