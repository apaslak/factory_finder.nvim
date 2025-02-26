local cache = {}

local function inspect_cache()
  local cache_contents = vim.inspect(cache)
  vim.notify(cache_contents, vim.log.levels.INFO)
end

local function load_cache()
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

  -- Use ripgrep to find all factory definitions
  local command = string.format('rg --line-number "factory\\(" --glob "**/factories/**" --type ruby %s', project_root)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  for line in result:gmatch("[^\r\n]+") do
    local filepath, lnum, factory = line:match("([^:]+):(%d+):%s*factory%(%s*(:[%w_]+)")
    if filepath and lnum and factory then
      if not cache[factory] then
        cache[factory] = {}
      end
      table.insert(cache[factory], { filename = filepath, lnum = tonumber(lnum) })
    end
  end
  vim.notify("Factory cache loaded.", vim.log.levels.INFO)
end

local function refresh_cache()
  cache = {}
  load_cache()
end

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
  if cache[factory_name] then
    return cache[factory_name]
  end

  refresh_cache()
  return cache[factory_name]
end

local function open_factory_definition(factory_name)
  local result = find_factory_definition(factory_name)

  if not result or #result == 0 then
    vim.notify("Factory '" .. factory_name .. "' not found.", vim.log.levels.ERROR)
    return
  end

  if #result > 1 then
    local qflist = {}
    for _, file in ipairs(result) do
      table.insert(qflist, {
        filename = file.filename,
        lnum = file.lnum,
        text = "Factory definition found in: " .. file.filename,
      })
    end

    vim.fn.setqflist(qflist, 'r')
    vim.cmd("copen")
  else
    vim.cmd("tabnew " .. result[1].filename)
    vim.cmd(":" .. result[1].lnum)
  end
end

local function go_to_factory_definition()
  local factory_name = parse_factory_name()

  if not factory_name then
    vim.notify("No factory name found on this line.", vim.log.levels.WARN)
    return nil
  end

  open_factory_definition(factory_name)
end

vim.api.nvim_create_user_command("FindFactory", go_to_factory_definition, { nargs = 0, desc = "Find FactoryBot definition" })
vim.api.nvim_create_user_command("RefreshFactoryCache", refresh_cache, { nargs = 0, desc = "Refresh FactoryBot cache" })
vim.api.nvim_create_user_command("InspectFactoryCache", inspect_cache, { nargs = 0, desc = "Inspect FactoryBot cache" })


load_cache()
