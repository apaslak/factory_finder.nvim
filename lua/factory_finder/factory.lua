local M = {}
local utils = require('factory_finder.utils')
local shared = require("nvim-treesitter.textobjects.shared")

function M.extend_treesitter()
  local query = [[
    ; @factories
    (call
      method: (identifier) @factory_method
      (#any-of? @factory_method
         "create"
         "build"
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

function M.identify_factory_name()
  local bufnr, _, function_node = shared.textobject_at_point("@factory_function", "factories")

  if function_node then
    local query = vim.treesitter.query.parse("ruby", "(simple_symbol) @factory_name")
    return utils.extract_item_name_from_query(query, function_node, bufnr)
  end

  return nil
end

function M.find_definition(factory_name)
  local project_root = utils.find_project_root()
  if not project_root then
    return
  end

  local command = string.format('rg --line-number "factory\\(%s" --glob "**/factories/**" --type ruby %s', factory_name, project_root)
  local items = utils.find_items(command)

  return items
end

function M.go_to_definition()
  local factory_name = M.identify_factory_name()
  if not factory_name then return end
  local result =  M.find_definition(factory_name)
  return utils.open_definition(result)
end

return M
