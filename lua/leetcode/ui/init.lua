local components = require("leetcode.ui.components")

local Split = require("nui.split")
local gql = require("leetcode.graphql")
local Popup = require("nui.popup")

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

---@param question lc.Problem
function Ui.create_leetcode_win(question) components.question.open(question) end

---@param question lc.Problem
function Ui.open_qot()
    local qot = gql.problems.question_of_today()

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

function Ui.testcase()
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
                top = " Testcase | r reset ",
                top_align = "center",
                -- bottom = "I am bottom title",
                -- bottom_align = "left",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = false,
        },
        win_options = {
            -- winblend = 10,
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
    })

    popup:mount()
end

return Ui
