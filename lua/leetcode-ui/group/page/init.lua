local Group = require("leetcode-ui.group")

---@class lc-menu.Page : lc-ui.Group
local Page = Group:extend("LeetMenuPage")

function Page:init(opts) --
    local options = vim.tbl_deep_extend("force", {
        position = "center",
        spacing = 1,
        padding = {
            top = 4,
        },
    }, opts or {})

    Page.super.init(self, {}, options)
end

---@type fun(): lc-menu.Page
local LeetMenuPage = Page

return LeetMenuPage
