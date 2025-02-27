local M = {}

function M.notify(message, level, config)
  if not config.suppress_notifications then
    vim.notify(message, level)
  end
end

function M.expand_home_directory(path)
  local home = os.getenv("HOME") or os.getenv("USERPROFILE")
  return path:gsub("^~", home)
end

function M.file_exists(filename)
  filename = M.expand_home_directory(filename)
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
  filename = M.expand_home_directory(filename)
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
  filename = M.expand_home_directory(filename)
  local file = io.open(filename, "r")
  if file then
    local content = file:read("*a")
    file:close()
    local func = load(content)
    if func then
      return func()
    else
      error("Could not load table from file " .. filename)
    end
  else
    error("Could not open file " .. filename .. " for reading.")
  end
end

function M.open_definition(result, item_name, config)
  if not result or #result == 0 then
    M.notify("Item '" .. item_name .. "' not found.", vim.log.levels.ERROR, config)
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
