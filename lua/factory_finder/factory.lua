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

return M
