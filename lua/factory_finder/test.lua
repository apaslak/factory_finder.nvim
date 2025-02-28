local utils = require('factory_finder.utils')
local factory_finder = require('factory_finder.factory')
local shared_example_finder = require('factory_finder.shared_example')
local shared_context_finder = require('factory_finder.shared_context')

function M.parse_context_name()
  local line = "  include_context('skip payroll mutation setup')"
  local example_name = line:match("include_context%s*[%(']([^%)'\"]+)[%'%)%s]*")
  -- local example_name = line:match("include_context%s+'(.-)'")

  return example_name
end




---

shared_context_finder.load_cache({})

M.cache = {}

local project_root = "/Users/amy.paslak/workspace/zenpayroll"
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
  -- local filepath, lnum, shared_context = line:match("([^:]+):(%d+):%s*shared_context%s*'(.-)'")
  local filepath, lnum, shared_context = line:match("^(.-):(%d+):.*shared_examples%s*['\"](.-)['\"]")
  if filepath and lnum and shared_context then
    if not M.cache[shared_context] then
      M.cache[shared_context] = {}
    end
    table.insert(M.cache[shared_context], { filename = filepath, lnum = tonumber(lnum) })
  end
end



local M = {}

function M.expand_home_directory(path)
  local home = os.getenv("HOME") or os.getenv("USERPROFILE")
  return path:gsub("^~", home)
end

function M.read_table_from_file(filename)
  filename = M.expand_home_directory(filename)
  local file = io.open(filename, "r")
  if file then
    local content = file:read("*a")
    print(content)
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

local cache = M.read_table_from_file("~/.dotfiles/factory_finder/factory.lua")
print(cache)

-- _base_address = { {
--     filename = "/Users/amy.paslak/workspace/zenpayroll/packs/technical_services/addresses/addresses/spec/factories/addresses/address_factory.rb",
--     lnum = 4
--   } },
-- _base_company_address = { {
--     filename = "/Users/amy.paslak/workspace/zenpayroll/packs/technical_services/addresses/addresses/spec/factories/company_address_factory.rb",
--     lnum = 4
--   } },
-- _base_contractor_address = { {
  --
-- /Users/amy.paslak/workspace/zenpayroll/spec/support/shared_contexts/payroll_item_runner.rb:186:  shared_examples 'the tax calculations are correct' do                                                                     │
-- /Users/amy.paslak/workspace/zenpayroll/spec/support/shared_contexts/payroll_item_runner.rb:177:  shared_examples 'it does not include these taxes' do                                                                      │
-- /Users/amy.paslak/workspace/zenpayroll/spec/support/shared_contexts/payroll_item_runner.rb:167:  shared_examples 'it includes the expected taxes' do                                                                       │
-- /Users/amy.paslak/workspace/zenpayroll/spec/support/shared_contexts/payroll_item_runner.rb:136:  shared_examples 'it is exempt from these taxes' do                                                                        │
-- /Users/amy.paslak/workspace/zenpayroll/spec/support/shared_behaviors/app_controller_helpers.rb:268:RSpec.shared_examples 'a write action that requires permission could be more than one' do |permission|                  │
-- /Users/amy.paslak/workspace/zenpayroll/spec/support/shared_behaviors/app_controller_helpers.rb:234:RSpec.shared_examples 'a write action that requires permission' do |permission|                                         │
-- /Users/amy.paslak/workspace/zenpayroll/spec/support/shared_behaviors/app_controller_helpers.rb:214:RSpec.shared_examples 'a read action that requires permission' do |permission|                                          │


-- /Users/amy.paslak/workspace/zenpayroll/spec/support/initializers/kafka.rb:61:RSpec.shared_context 'kafka enabled' do                                                                                                       │
-- /Users/amy.paslak/workspace/zenpayroll/packs/product_services/time/time_tracking/spec/support/controller_setup.rb:5:  RSpec.shared_context('controller setup') do                                                          │
-- /Users/amy.paslak/workspace/zenpayroll/packs/product_services/time/time_tracking/spec/support/zp_mocks.rb:5:  RSpec.shared_context('zp mocks') do                                                                          │
-- /Users/amy.paslak/workspace/zenpayroll/packs/product_services/benefits/enrollments/spec/support/shared_contexts/hawaiian_ice/enrollment_flow.rb:3:RSpec.shared_context('enrollment flow') do                               │
-- /Users/amy.paslak/workspace/zenpayroll/packs/product_services/benefits/enrollments/spec/support/shared_contexts/hawaiian_ice/hsa/direct_enrollment_flow.rb:3:RSpec.shared_context('hsa direct enrollment flow') do         │
-- /Users/amy.paslak/workspace/zenpayroll/packs/technical_services/auth/authorization/spec/public/app_blocked_companies_spec.rb:13:  shared_context 'with app blocked companies' do                                           │
--
