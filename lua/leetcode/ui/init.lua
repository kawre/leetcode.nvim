---@class lc.UI
local Ui = {}

---@param items table
---@param prompt? string
---@param format_fn? fun(table):string
---@param callback fun(table)
function Ui.pick_one(items, prompt, format_fn, callback)
    vim.ui.select(items, {
        prompt = prompt or "",
        format_item = format_fn or function(item) return item end,
        telescope = require("telescope.themes").get_dropdown(),
    }, callback)
end

function Ui.input(opts, callback) vim.ui.input(opts, callback) end

return Ui
