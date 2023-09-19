---@class lc.Utils
local Utils = {}

function Utils.remove_cookie()
  require("leetcode.cache.cookie").delete()
  require("leetcode.ui.dashboard").update()
end

function Utils.alpha_move_cursor_top()
  local curr_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_cursor(curr_win, { 1, 0 })
  require("alpha").move_cursor(curr_win)
end

---Extracts an HTML tag from a string.
---
---@param str string The input string containing HTML tags.
---@return string | nil The extracted HTML tag, or nil if no tag is found.
function Utils.get_html_tag(str) return str:match("^<(.-)>") end

---@param str string
---@param tag string
---
---@return string
function Utils.strip_html_tag(str, tag)
  local regex = string.format("^<%s>(.*)</%s>$", tag, tag)
  assert(str:match(regex))

  local offset = 3 + tag:len()
  return str:sub(offset, str:len() - offset)
end

return Utils
