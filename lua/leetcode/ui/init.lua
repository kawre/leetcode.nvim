---@class lc.UI
local Ui = {}

---@param items table
---@param prompt? string
---@param fn? fun(table)
---@param callback fun(table)
function Ui.pick_one(items, prompt, fn, callback)
  vim.ui.select(items, {
    prompt = prompt or "",
    format_item = fn or function(item) return item end,
    telescope = require("telescope.themes").get_dropdown(),
  }, callback)
end

function Ui.input(opts, callback) vim.ui.input(opts, callback) end

function Ui.oldfiles() Ui.create_win() end

function Ui.create_win()
  -- We save handle to window from which we open the navigation
  start_win = vim.api.nvim_get_current_win()

  vim.api.nvim_command("topleft vnew") -- We open a new vertical window at the far right
  win = vim.api.nvim_get_current_win() -- We save our navigation window handle...
  buf = vim.api.nvim_get_current_buf() -- ...and it's buffer handle.

  -- We should name our buffer. All buffers in vim must have unique names.
  -- The easiest solution will be adding buffer handle to it
  -- because it is already unique and it's just a number.
  vim.api.nvim_buf_set_name(buf, "Oldfiles #" .. buf)

  -- Now we set some options for our buffer.
  -- nofile prevent mark buffer as modified so we never get warnings about not saved changes.
  -- Also some plugins treat nofile buffers different.
  -- For example coc.nvim don't triggers aoutcompletation for these.
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  -- We do not need swapfile for this buffer.
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  -- And we would rather prefer that this buffer will be destroyed when hide.
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  -- It's not necessary but it is good practice to set custom filetype.
  -- This allows users to create their own autocommand or colorschemes on filetype.
  -- and prevent collisions with other plugins.
  vim.api.nvim_buf_set_option(buf, "filetype", "leetcode.nvim")

  -- For better UX we will turn off line wrap and turn on current line highlight.
  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.api.nvim_win_set_option(win, "cursorline", true)

  set_mappings() -- At end we will set mappings for our navigation.
end

return Ui
