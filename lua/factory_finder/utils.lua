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
      return name
    end
  end
end

function M.find_project_root()
  local project_root = vim.fn.getcwd()

  while project_root ~= "/" do
    if vim.fn.filereadable(project_root .. "/Gemfile") == 1 then break end
    project_root = vim.fn.fnamemodify(project_root, ":h")
  end

  if vim.fn.filereadable(project_root .. "/Gemfile") ~= 1 then
    return nil
  end

  return project_root
end

local function execute_command(command)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    return result
end

function M.find_items(command, matcher)
  local item_files = {}

  local result = execute_command(command)

  for line in result:gmatch("[^\r\n]+") do
    local filepath, lnum, item = line:match(matcher)
    if filepath and lnum and item then
      if not item_files[item] then
        item_files[item] = {}
      end
      table.insert(item_files[item], { filename = filepath, lnum = tonumber(lnum) })
    end
  end

  return item_files
end

function M.open_definition(result)
  if not result or #result == 0 then
    return false
  end

  if #result > 1 then
    local qflist = {}
    for _, file in ipairs(result) do
      table.insert(qflist, {
        filename = file.filename,
        lnum = file.lnum,
      })
    end

    vim.fn.setqflist(qflist, 'r')
    vim.cmd("copen")
    return true
  else
    vim.cmd("tabnew " .. result[1].filename)
    vim.cmd(":" .. result[1].lnum)
    return true
  end
end

return M
