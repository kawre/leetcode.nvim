local Text = require("leetcode-ui.component.text")

---@class lc-menu.Title : lc-ui.Text
---@field text lc-ui.Text
local title = {}
title.__index = title
setmetatable(title, Text)

---@param str string
---@param opts? any
function title:init(str, opts)
    opts = vim.tbl_deep_extend("force", {
        position = "center",
        hl = "Function",
    }, opts or {})

    local text = Text:init({
        lines = { str },
        opts = opts,
    })

    local obj = setmetatable(text, self)
    return obj
end

return title
