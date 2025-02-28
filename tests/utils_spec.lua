package.path = package.path .. ';./tests/?.lua;./lua/?.lua;./lua/?/init.lua'

local utils = require('factory_finder.utils')
local tables_equal = require('spec_helper').tables_equal

describe("serialize_table", function()
  it("should serialize an array-like table", function()
    local t = { "apple", "banana", "cherry" }
    local expected = '{\n  "apple",\n  "banana",\n  "cherry",\n}'
    assert.is_true(tables_equal(utils.serialize_table(t), expected))
  end)

  it("should serialize a dictionary-like table", function()
    local t = { a = "apple", b = "banana", c = 42 }
    local expected = '{\n  ["a"] = "apple",\n  ["b"] = "banana",\n  ["c"] = 42,\n}'
    assert.is_true(tables_equal(utils.serialize_table(t), expected))
  end)

  it("should handle nested tables", function()
    local t = { a = { x = 1, y = 2 }, b = "banana" }
    local expected = '{\n  ["a"] = {\n    ["x"] = 1,\n    ["y"] = 2,\n  },\n  ["b"] = "banana",\n}'
    assert.is_true(tables_equal(utils.serialize_table(t), expected))
  end)

  it("should handle empty tables", function()
    local t = {}
    local expected = '{\n}'
    assert.is_true(tables_equal(utils.serialize_table(t), expected))
  end)

  it("should handle mixed key types", function()
    local t = { [1] = "one", ["two"] = 2 }
    local expected = '{\n  [1] = "one",\n  ["two"] = 2,\n}'
    assert.is_true(tables_equal(utils.serialize_table(t), expected))
  end)
end)

