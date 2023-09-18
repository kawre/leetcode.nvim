local ui = require("leetcode.ui")

---@class lc.Utils
local Utils = {}

function Utils.prompt_for_cookie()
  local cookie = require("leetcode.cache.cookie")

  ui.input(
    "Enter cookie",
    ---@param cookie_str string
    function(cookie_str)
      if not cookie_str then return end

      cookie.new(cookie_str)
      require("leetcode.ui.dashboard").update()
    end
  )
end

function Utils.remove_cookie()
  require("leetcode.cache.cookie").delete()
  require("leetcode.ui.dashboard").update()
end

function Utils.alpha_move_cursor_top()
  local curr_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_cursor(curr_win, { 1, 0 })
  require("alpha").move_cursor(curr_win)
end

return Utils
