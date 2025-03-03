local M = {}
local utils = require('factory_finder.utils')
local shared = require("nvim-treesitter.textobjects.shared")

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

function M.identify_shared_example_name()
  local bufnr, _, function_node = shared.textobject_at_point("@shared_example", "shared_examples")

  if function_node then
    local query = vim.treesitter.query.parse("ruby", "(string) @example_name")
    return utils.extract_item_name_from_query(query, function_node, bufnr)
  end

  return nil
end

return M
