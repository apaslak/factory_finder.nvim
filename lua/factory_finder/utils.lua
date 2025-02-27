local M = {}

function M.notify(message, level, config)
  if not config.suppress_notifications then
    vim.notify(message, level)
  end
end

return M
