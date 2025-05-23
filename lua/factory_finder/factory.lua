local M = {}
local utils = require('factory_finder.utils')
local file_utils = require('factory_finder.file_utils')
local shared = require("nvim-treesitter.textobjects.shared")
local filename = "factory.lua"
local cache = {}

function M.extend_treesitter()
  local query = [[
    ; @factories
    (call
      method: (identifier) @factory_method
      (#any-of? @factory_method
         "create"
         "build"
         "build_stubbed"
         "attributes_for"
         "attributes_for_list"
         "build_list"
         "create_list"
         "build_stubbed_list"
         "create_pair"
         "build_pair"
         "build_stubbed_pair"
         "attributes_for_pair"
         )
      arguments: (argument_list
        (simple_symbol) @factory_name
        (pair
          key: (hash_key_symbol)
          value: (identifier)
        )*
      )
    ) @factory_function
  ]]
  vim.treesitter.query.set("ruby", "factories", query)
end

function M.load_cache()
  if file_utils.file_exists(filename) then
    cache = file_utils.read_table_from_file(filename)
    -- vim.notify("[load_cache:factory] read from file")
    return cache
  end
  -- vim.notify("[load_cache:factory] refreshed cache")
  M.refresh_cache()
  return cache
end

function M.refresh_cache()
  cache = {}

  local project_root = utils.find_project_root()
  if not project_root then
    return
  end

  local command = string.format('rg --line-number "factory\\(" --glob "**/factories/**" --type ruby %s', project_root)
  local matcher = "([^:]+):(%d+):%s*factory%(%s*(:[%w_]+)"
  cache = utils.find_items(command, matcher)

  file_utils.write_table_to_file(cache, filename)

  return cache
end

function M.inspect_cache()
  local cache_contents = vim.inspect(cache)
  vim.notify(cache_contents)
end

function M.identify_name()
  local bufnr, _, function_node = shared.textobject_at_point("@factory_function", "factories")

  if function_node then
    local query = vim.treesitter.query.parse("ruby", "(simple_symbol) @factory_name")
    return utils.extract_item_name_from_query(query, function_node, bufnr)
  end

  return nil
end

function M.find_definition(item_name)
  if cache[item_name] then
    return cache[item_name]
  end

  M.refresh_cache()
  return cache[item_name]
end

function M.go_to_definition(config)
  local item_name = M.identify_name()
  if not item_name then
    return false
  end

  local result = M.find_definition(item_name)
  utils.open_definition(result, config)

  return true
end

return M
