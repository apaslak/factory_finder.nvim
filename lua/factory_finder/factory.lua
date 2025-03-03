local M = {}

function M.extend_treesitter()
  local factory_function_query = [[
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
  vim.treesitter.query.set("ruby", "factories", factory_function_query)
end

function M.identify_factory_name()
  local shared = require("nvim-treesitter.textobjects.shared")
  local bufnr, _, function_node = shared.textobject_at_point("@factory_function", "factories")

  if function_node then
    local query = vim.treesitter.query.parse("ruby", "(simple_symbol) @factory_name")

    if query then
      local matches = {}
      for id, node, text_range in query:iter_captures(function_node, bufnr) do
        table.insert(matches, { node, id, text_range })
      end

      if #matches > 0 then
        local factory_name_node = matches[1][1]
        local factory_name = vim.treesitter.get_node_text(factory_name_node, bufnr)
        vim.print("Factory name:", factory_name)
        return factory_name
      end
    else
      vim.print("Query parsing failed.")
    end
  end

  return nil
end

return M
