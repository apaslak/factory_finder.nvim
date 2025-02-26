local function find_factory_definition(factory_name)
  -- 1. Project Root Detection
  local project_root = vim.fn.getcwd()
  while project_root ~= "/" do
    if vim.fn.filereadable(project_root .. "/Gemfile") == 1 then break end
    project_root = vim.fn.fnamemodify(project_root, ":h")
  end
  if vim.fn.filereadable(project_root .. "/Gemfile") ~= 1 then
    vim.notify("Could not find project root (Gemfile)", vim.log.levels.ERROR)
    return
  end

  -- 2. Use ripgrep to search for the factory definition
  local command = string.format('rg --files-with-matches "factory\\(%s" %s', factory_name, project_root)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  -- 3. Process ripgrep output
  if result == "" then
    vim.notify("Factory '" .. factory_name .. "' not found.", vim.log.levels.ERROR)
    return nil
  end

  local factory_files = {}
  for line in result:gmatch("[^\r\n]+") do
    table.insert(factory_files, line)
  end

  -- 4. If multiple files are found, prompt the user to select one
  if #factory_files > 1 then
    local qflist = {}
    for _, file in ipairs(factory_files) do
      table.insert(qflist, {
        filename = file,
        lnum = 1,  -- Default to line number 1, you may adjust if you want to search for specific lines later
        text = "Factory definition found in: " .. file,
      })
    end

    -- Set the quickfix list without the title argument
    vim.fn.setqflist(qflist, 'r')
    vim.cmd("copen")  -- Open the quickfix list
  else
    vim.cmd("tabnew " .. factory_files[1])
  end
end

local function open_factory_definition()
  -- 1. Get the current line
  local current_line = vim.fn.getline(".")

  -- 2. Extract the factory name using a regular expression
  local factory_name = current_line:match("build%(([^)]+)%)")
    or current_line:match("create%(([^)]+)%)")
    or current_line:match("factory%(([^)]+)%)")

  if not factory_name then
    vim.notify("No factory name found on this line.", vim.log.levels.WARN)
    return
  end

  factory_name = factory_name:gsub("['\"]", "") -- Remove quotes

  -- 3. Find the factory definition (this now handles file opening as well)
  find_factory_definition(factory_name)
end

-- 4. Create a Neovim command
vim.api.nvim_create_user_command("FindFactory", open_factory_definition, { nargs = 0, desc = "Find FactoryBot definition" })

print("FactoryFinder plugin loaded.")
