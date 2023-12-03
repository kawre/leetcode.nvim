local Group = require("leetcode-ui.group")
local log = require("leetcode.logger")

---@class lc.ui.Buttons : lc.ui.Group
local Buttons = Group:extend("LeetButtons")

function Buttons:init(buttons, opts)
    opts = vim.tbl_deep_extend("force", {
        padding = {
            bot = 1,
        },
        spacing = 1,
    }, opts or {})

    Buttons.super.init(self, buttons, opts)
end

---@type fun(buttons?: lc.ui.Button[], opts?: table): lc.ui.Buttons
local LeetButtons = Buttons

return LeetButtons
