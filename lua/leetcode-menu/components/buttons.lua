local Group = require("leetcode-ui.component.group")

---@class lc-menu.Buttons : lc-ui.Group
local Buttons = {}
Buttons.__index = Buttons
setmetatable(Buttons, Group)

function Buttons:init(config)
    config = vim.tbl_deep_extend("force", {
        opts = {
            padding = {
                top = 1,
                bot = 1,
            },
            spacing = 1,
        },
    }, config)

    local group = Group:init(config)
    return setmetatable(group, self)
end

return Buttons
