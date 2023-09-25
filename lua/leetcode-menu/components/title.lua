local Text = require("leetcode-ui.component.text")

---@class lc-menu.Title
---@field text lc-ui.Text
local title = {}
title.__index = title

function title:content() return self.text end

---@param str string
---@param opts? any
function title:init(str, opts)
    opts = vim.tbl_deep_extend("force", {
        position = "center",
        hl = "Comment",
    }, opts or {})

    local text = Text:init({
        lines = { str },
        opts = opts,
    })

    local obj = setmetatable({
        text = text,
    }, self)

    return obj
end

return title
