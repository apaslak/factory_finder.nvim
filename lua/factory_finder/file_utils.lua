local M = {}
local cache_dir = vim.fn.stdpath('cache') .. '/factory_finder/'
local repo_dir

function M.get_or_create_repo_dir(project_root)
  -- create plugin dir
  if not vim.loop.fs_stat(cache_dir) then
    vim.loop.fs_mkdir(cache_dir, 493) -- 493 is the octal permission 0755
  end

  -- create plugin/repo dir
  local repo_name = vim.fn.fnamemodify(project_root, ':t')
  repo_dir = cache_dir .. repo_name

  if not vim.loop.fs_stat(repo_dir) then
    vim.loop.fs_mkdir(repo_dir, 493) -- 493 is the octal permission 0755
  end

  repo_dir = repo_dir .. "/"

  return repo_dir
end

function M.file_exists(filename)
  filename = repo_dir .. filename
  local file = io.open(filename, "r")
  if file then
    file:close()
    return true
  else
    return false
  end
end

function M.serialize_table(t, indent)
  indent = indent or ""
  local result = "{\n"
  local next_indent = indent .. "  "

  -- Use a flag to check if the table is an array
  local is_array = true

  for k, v in pairs(t) do
    if type(k) ~= "number" then
      is_array = false
      break
    end
  end

  if is_array then
    -- If it's an array-like table, we serialize without keys
    for _, v in ipairs(t) do
      local value
      if type(v) == "table" then
        value = M.serialize_table(v, next_indent)
      elseif type(v) == "string" then
        value = string.format("%q", v)
      else
        value = tostring(v)
      end

      result = result .. next_indent .. value .. ",\n"
    end
  else
    -- If it's a dictionary-like table, keep the original serialization
    for k, v in pairs(t) do
      local key = "[" .. string.format("%q", k) .. "]"
      local value
      if type(v) == "table" then
        value = M.serialize_table(v, next_indent)
      elseif type(v) == "string" then
        value = string.format("%q", v)
      else
        value = tostring(v)
      end

      result = result .. next_indent .. key .. " = " .. value .. ",\n"
    end
  end

  result = result .. indent .. "}"
  return result
end

function M.write_table_to_file(t, filename)
  filename = repo_dir .. filename
  local file = io.open(filename, "w")
  if file then
    local serialized_table = M.serialize_table(t)
    file:write("return " .. serialized_table)
    file:close()
  else
    error("Could not open file " .. filename .. " for writing.")
  end
end

function M.read_table_from_file(filename)
  return require(cache_dir .. filename)
end

return M
