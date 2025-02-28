local M = {}

M.utils = require('factory_finder.utils')
M.filename = "~/.dotfiles/factory_finder/shared_context.lua"

M.cache = {}

function M.load_cache(config)
  if M.utils.file_exists(M.filename) then
    -- M.utils.notify("Shared context file exists!", vim.log.levels.INFO, config)
    M.cache = M.utils.read_table_from_file(M.filename)
    return M.cache
  end
  M.refresh_cache(config)
  return M.cache
end

function M.refresh_cache(config)
  M.cache = {}

  local project_root = vim.fn.getcwd()
  while project_root ~= "/" do
    if vim.fn.filereadable(project_root .. "/Gemfile") == 1 then break end
    project_root = vim.fn.fnamemodify(project_root, ":h")
  end
  if vim.fn.filereadable(project_root .. "/Gemfile") ~= 1 then
    return
  end

  local command = string.format('rg --line-number "shared_context" --type ruby %s', project_root)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  for line in result:gmatch("[^\r\n]+") do
    local filepath, lnum, shared_context = line:match("^(.-):(%d+):.*['\"](.-)['\"]")
    if filepath and lnum and shared_context then
      if not M.cache[shared_context] then
        M.cache[shared_context] = {}
      end
      table.insert(M.cache[shared_context], { filename = filepath, lnum = tonumber(lnum) })
    end
  end
  M.utils.notify("shared_context cache loaded.", vim.log.levels.INFO, config)

  M.utils.write_table_to_file(M.cache, M.filename)
end

function M.inspect_cache(config)
  local cache_contents = vim.inspect(M.cache)
  M.utils.notify(cache_contents, vim.log.levels.INFO, config)
end

function M.parse_context_name()
  local line = vim.api.nvim_get_current_line()
  local example_name = line:match("include_context[%s%(]*['\"]([^'\"]+)['\"][%s%)].*")

  return example_name
end

function M.find_definition(context_name, config)
  if M.cache[context_name] then
    return M.cache[context_name]
  end

  M.refresh_cache(config)
  return M.cache[context_name]
end

function M.go_to_definition(config)
  local context_name = M.parse_context_name()

  if not context_name then
    M.utils.notify("No shared_context found on this line.", vim.log.levels.WARN, config)
    return nil
  end

  local result = M.find_definition(context_name, config)
  return M.utils.open_definition(result, context_name, config)
end

return M
