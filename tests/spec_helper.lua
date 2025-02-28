M = {}

function M.tables_equal(t1, t2)
  for k, v in pairs(t1) do
    if type(v) == "table" and type(t2[k]) == "table" then
      if not M.tables_equal(v, t2[k]) then return false end
    elseif v ~= t2[k] then
      return false
    end
  end
  for k, v in pairs(t2) do
    if type(v) == "table" and type(t1[k]) == "table" then
      if not M.tables_equal(v, t1[k]) then return false end
    elseif v ~= t1[k] then
      return false
    end
  end
  return true
end

return M
