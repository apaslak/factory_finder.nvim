local M = {}
local utils = require('factory_finder.utils')
local file_utils = require('factory_finder.file_utils')
local shared = require("nvim-treesitter.textobjects.shared")
local filename = "shared_example.lua"
local cache = {}

function M.extend_treesitter()
  local query = [[
    (call
      method: (identifier) @group_name
      (#any-of? @group_name
         "include_examples"
         "it_should_behave_like"
         "it_behaves_like"
         )
      arguments: (argument_list
        (string) @example_name
      )
    ) @shared_example
  ]]
  vim.treesitter.query.set("ruby", "shared_examples", query)
end

function M.load_cache()
  if file_utils.file_exists(filename) then
    cache = file_utils.read_table_from_file(filename)
    -- vim.notify("[load_cache:shared_example] read from file")
    return cache
  end
  -- vim.notify("[load_cache:shared_example] refreshed cache")
  M.refresh_cache()
  return cache
end

function M.refresh_cache()
  cache = {}

  local project_root = utils.find_project_root()
  if not project_root then
    return
  end

  local command = string.format('rg --line-number "shared_examples(_for)?" --type ruby %s', project_root)
  local matcher = "^(.-):(%d+):.*shared_examples%s*['\"](.-)['\"]"
  cache = utils.find_items(command, matcher)

  file_utils.write_table_to_file(cache, filename)

  return cache
end

function M.inspect_cache()
  local cache_contents = vim.inspect(cache)
  vim.notify(cache_contents)
end

function M.identify_name()
  local bufnr, _, function_node = shared.textobject_at_point("@shared_example", "shared_examples")

  if function_node then
    local query = vim.treesitter.query.parse("ruby", "(string) @example_name")
    local name = utils.extract_item_name_from_query(query, function_node, bufnr)
    -- strip quotation marks
    local clean_name = name:gsub('^["\'](.*)["\']$', '%1')
    -- vim.print({"name: " .. clean_name})
    return clean_name
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
