local Text = require("leetcode-ui.component.text")

---@class lc-menu.Notifications : lc-ui.Text
---@field text lc-ui.Text
local notifications = {}
notifications.__index = notifications
setmetatable(notifications, Text)

---@param opts? any
function notifications:init(opts)
    opts = vim.tbl_deep_extend("force", {
        position = "center",
        hl = "DiagnosticInfo",
    }, opts or {})

    local text = Text:init({
        opts = opts,
    })

    local obj = setmetatable(text, self)
    return obj
end

return notifications
