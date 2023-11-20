local Text = require("leetcode-ui.component.text")
local NuiLine = require("nui.line")
local t = require("leetcode.translator")
local log = require("leetcode.logger")

---@class lc-menu.Title : lc-ui.Text
---@field text lc-ui.Text
local title = {}
title.__index = title
setmetatable(title, Text)

---@param history string[]
---@param str string
---@param opts? any
function title:init(history, str, opts)
    history = vim.tbl_map(t, history)
    str = t(str)

    opts = vim.tbl_deep_extend("force", {
        position = "center",
    }, opts or {})

    local nui_line = NuiLine()
    for _, h in ipairs(history) do
        nui_line:append(h, "leetcode_alt")
        nui_line:append("  ", "leetcode_list")
    end
    nui_line:append(str, "Function")

    local text = Text:init({ nui_line }, opts)

    return setmetatable(text, self)
end

return title
