local Group = require("leetcode-ui.component.group")

---@class lc-menu.Buttons : lc-ui.Group
local Buttons = {}
Buttons.__index = Buttons
setmetatable(Buttons, Group)

function Buttons:init(components, opts)
    opts = vim.tbl_deep_extend("force", {
        padding = {
            top = 1,
            bot = 2,
        },
        spacing = 1,
    }, opts or {})

    local group = Group:init(components, opts)
    return setmetatable(group, self)
end

return Buttons
