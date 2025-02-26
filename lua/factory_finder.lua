local function parse_factory_name()
  -- Get the current line
  -- TEST
  local current_line = vim.fn.getline(".")

  -- Extract the factory name using a regular expression
  local factory_name = current_line:match("build%(([^)]+)%)")
    or current_line:match("create%(([^)]+)%)")
    or current_line:match("factory%(([^)]+)%)")

  return factory_name
end

local function find_factory_definition(factory_name)
  -- Project Root Detection
  local project_root = vim.fn.getcwd()
  -- TEST
  while project_root ~= "/" do
    if vim.fn.filereadable(project_root .. "/Gemfile") == 1 then break end
    project_root = vim.fn.fnamemodify(project_root, ":h")
  end
  if vim.fn.filereadable(project_root .. "/Gemfile") ~= 1 then
    vim.notify("Could not find project root (Gemfile)", vim.log.levels.ERROR)
    return
  end

  -- Use ripgrep to search for the factory definition
  local command = string.format('rg --line-number "factory\\(%s" --glob "**/factories/**" %s', factory_name, project_root)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  return result
end

local function open_factory_definition(factory_name)
  -- Find the factory definition (this now handles file opening as well)
  local result = find_factory_definition(factory_name)

  local factory_files = {}
  for line in result:gmatch("[^\r\n]+") do
    local filepath, lnum = line:match("([^:]+):(%d+):")
    if filepath and lnum then
      table.insert(factory_files, { filename = filepath, lnum = tonumber(lnum) })
    end
  end

  -- If multiple files are found, prompt the user to select one
  if #factory_files > 1 then
    local qflist = {}
    for _, file in ipairs(factory_files) do
      table.insert(qflist, {
        filename = file.filename,
        lnum = file.lnum,
        text = "Factory definition found in: " .. file.filename,
      })
    end

    -- Set the quickfix list without the title argument
    vim.fn.setqflist(qflist, 'r')
    -- Open the quickfix list
    vim.cmd("copen")
  elseif #factory_files == 1 then
    vim.cmd("tabnew " .. factory_files[1].filename)
    vim.cmd(":" .. factory_files[1].lnum)
  end
end

local function go_to_factory_definition()
  local factory_name = parse_factory_name()

  if not factory_name then
    vim.notify("No factory name found on this line.", vim.log.levels.WARN)
    return nil
  end

  local result = find_factory_definition(factory_name)

  if result == "" then
    vim.notify("Factory '" .. factory_name .. "' not found.", vim.log.levels.ERROR)
    return nil
  end

  open_factory_definition(factory_name)
end

-- 4. Create a Neovim command
vim.api.nvim_create_user_command("FindFactory", go_to_factory_definition, { nargs = 0, desc = "Find FactoryBot definition" })
