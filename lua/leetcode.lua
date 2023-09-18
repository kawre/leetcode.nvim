local config = require("leetcode.config")
local api = require("leetcode.api")

local M = {}

---@param cfg? lc.Config
function M.setup(cfg)
  config.apply(cfg or {})

  vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    nested = true,
    callback = function()
      if config.user.invoke_name == vim.fn.expand("%") then api.cmd.leetcode() end
    end,
  })
end

return M
