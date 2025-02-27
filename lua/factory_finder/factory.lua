local M = {}

local utils = require('factory_finder.utils')

local cache = {}

function M.load_cache(config)
  local project_root = vim.fn.getcwd()
  while project_root ~= "/" do
    if vim.fn.filereadable(project_root .. "/Gemfile") == 1 then break end
    project_root = vim.fn.fnamemodify(project_root, ":h")
  end
  if vim.fn.filereadable(project_root .. "/Gemfile") ~= 1 then
    return
  end

  local command = string.format('rg --line-number "factory\\(" --glob "**/factories/**" --type ruby %s', project_root)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  for line in result:gmatch("[^\r\n]+") do
    local filepath, lnum, factory = line:match("([^:]+):(%d+):%s*factory%(%s*:([%w_]+)")
    if filepath and lnum and factory then
      if not cache[factory] then
        cache[factory] = {}
      end
      table.insert(cache[factory], { filename = filepath, lnum = tonumber(lnum) })
    end
  end
  utils.notify("Factory cache loaded.", vim.log.levels.INFO, config)
end

function M.refresh_cache(config)
  cache = {}
  M.load_cache(config)
end

function M.inspect_cache(config)
  local cache_contents = vim.inspect(cache)
  utils.notify(cache_contents, vim.log.levels.INFO, config)
end

local function parse_factory_name()
  local line_nr = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]

  if not line then
    return nil
  end

  local factory_match = line:match("build%(([^)]+)") or line:match("create%(([^)]+)")
  if factory_match then
    local factory_name = factory_match:match("[:%s]*([^,%s)]+)")
    if factory_name then
      return factory_name
    end
  end

  local start_line = line_nr - 1
  local end_line = vim.api.nvim_buf_line_count(0)

  for i = start_line + 1, end_line do
    local next_line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
    if next_line:match("%)") then
      local combined_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, i, false)
      local combined_text = table.concat(combined_lines, " ")
      local factory_match_multi = combined_text:match("build%(([^)]+)") or combined_text:match("create%(([^)]+)")
      if factory_match_multi then
        local factory_name_multi = factory_match_multi:match("[:%s]*([^,%s)]+)")
        if factory_name_multi then
          return factory_name_multi
        end
      end
      break
    end
  end
  return nil
end

local function find_factory_definition(factory_name)
  if cache[factory_name] then
    return cache[factory_name]
  end

  M.refresh_cache()
  return cache[factory_name]
end

local function open_factory_definition(factory_name)
  local result = find_factory_definition(factory_name)

  if not result or #result == 0 then
    utils.notify("Factory '" .. factory_name .. "' not found.", vim.log.levels.ERROR)
    return
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
  else
    vim.cmd("tabnew " .. result[1].filename)
    vim.cmd(":" .. result[1].lnum)
  end
end

function M.go_to_factory_definition()
  local factory_name = parse_factory_name()

  if not factory_name then
    utils.notify("No factory name found on this line.", vim.log.levels.WARN)
    return nil
  end

  open_factory_definition(factory_name)
end

return M
