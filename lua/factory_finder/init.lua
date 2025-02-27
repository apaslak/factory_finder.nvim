local M = {}

local default_config = {
  suppress_notifications = false,
}

M.config = {}

local utils = require('factory_finder.utils')
local factory_finder = require('factory_finder.factory')
local shared_example_finder = require('factory_finder.shared_example')

function M.setup(user_config)
  M.config = vim.tbl_extend("force", default_config, user_config or {})

  factory_finder.load_cache(M.config)
  shared_example_finder.load_cache(M.config)
end

-- this method relies on just the caches to be populated
local function smart_go_to_definition(config)
  local result

  local item_name = factory_finder.parse_factory_name()
  if item_name then
    result = factory_finder.find_definition(item_name, config)
    return utils.open_definition(result, item_name, config)
  end

  item_name = shared_example_finder.parse_example_name()
  if item_name then
    result = shared_example_finder.find_definition(item_name, config)
    return utils.open_definition(result, item_name, config)
  end

  utils.notify("No item found on this line.", vim.log.levels.WARN, config)
end

local function refresh_caches(config)
  factory_finder.refresh_cache(config)
  shared_example_finder.refresh_cache(config)
end

local function inspect_caches(config)
  factory_finder.inspect_cache(config)
  shared_example_finder.inspect_cache(config)
end

vim.api.nvim_create_user_command("SmartGoToDefinition", function() smart_go_to_definition(M.config) end, { nargs = 0, desc = "Find FactoryBot, shared_example, or shared_context definition" })
vim.api.nvim_create_user_command("RefreshCaches", function() refresh_caches(M.config) end, { nargs = 0, desc = "Refresh all caches" })
vim.api.nvim_create_user_command("InspectCaches", function() inspect_caches(M.config) end, { nargs = 0, desc = "Inspect all caches" })

vim.api.nvim_create_user_command("FactoryGoToDefinition", function() factory_finder.go_to_definition(M.config) end, { nargs = 0, desc = "Find FactoryBot definition" })
vim.api.nvim_create_user_command("RefreshFactoryCache", function() factory_finder.refresh_cache(M.config) end, { nargs = 0, desc = "Refresh FactoryBot cache" })
vim.api.nvim_create_user_command("InspectFactoryCache", function() factory_finder.inspect_cache(M.config) end, { nargs = 0, desc = "Inspect FactoryBot cache" })

vim.api.nvim_create_user_command("SharedExampleGoToDefinition", function() shared_example_finder.go_to_definition(M.config) end, { nargs = 0, desc = "Find shared_example definition" })
vim.api.nvim_create_user_command("RefreshSharedExampleCache", function() shared_example_finder.refresh_cache(M.config) end, { nargs = 0, desc = "Refresh shared_example cache" })
vim.api.nvim_create_user_command("InspectSharedExampleCache", function() shared_example_finder.inspect_cache(M.config) end, { nargs = 0, desc = "Inspect shared_example cache" })

return M
