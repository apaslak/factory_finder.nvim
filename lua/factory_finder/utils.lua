local M = {}

function M.extract_item_name_from_query(query, function_node, bufnr)
  if query then
    local matches = {}
    for id, node, text_range in query:iter_captures(function_node, bufnr) do
      table.insert(matches, { node, id, text_range })
    end

    if #matches > 0 then
      local name_node = matches[1][1]
      local name = vim.treesitter.get_node_text(name_node, bufnr)
      vim.print("Item name:", name)
      return name
    end
  else
    vim.print("Query parsing failed.")
  end
end

return M
