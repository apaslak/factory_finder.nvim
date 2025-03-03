local M = {}
local utils = require('factory_finder.utils')
local shared = require("nvim-treesitter.textobjects.shared")

function M.extend_treesitter()
  local query = [[
    (call
      method: (identifier) @group_name
      (#eq? @group_name "include_context")
      arguments: (argument_list
        (string) @context_name
      )
    ) @shared_context
  ]]
  vim.treesitter.query.set("ruby", "shared_contexts", query)
end

function M.identify_shared_context_name()
  local bufnr, _, function_node = shared.textobject_at_point("@shared_context", "shared_contexts")

  if function_node then
    local query = vim.treesitter.query.parse("ruby", "(string) @context_name")
    return utils.extract_item_name_from_query(query, function_node, bufnr)
  end

  return nil
end

return M
