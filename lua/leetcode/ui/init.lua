local api_problems = require("leetcode.api.problems")
local Popup = require("nui.popup")

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

--@param question lc.Problem
function Ui.open_qot()
    local qot = api_problems.question_of_today()

    local popup = Popup({
        position = "50%",
        size = {
            width = 80,
            height = 40,
        },
        enter = true,
        focusable = true,
        zindex = 50,
        relative = "editor",
        border = {
            padding = {
                top = 2,
                bottom = 2,
                left = 3,
                right = 3,
            },
            style = "rounded",
            text = {
                top = " I am top title ",
                top_align = "center",
                bottom = "I am bottom title",
                bottom_align = "left",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = false,
        },
        win_options = {
            winblend = 10,
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
    })
end

return Ui
