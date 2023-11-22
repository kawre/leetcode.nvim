local Group = require("leetcode-ui.group")

---@class lc-menu.Page : lc-ui.Renderer
local Page = Group:extend("LeetMenuPage")

function Page:init(opts) --
    local options = vim.tbl_deep_extend("force", {
        position = "center",
    }, opts or {})

    Page.super.init(self, options)
end

---@type fun(): lc-menu.Page
local LeetMenuPage = Page

return LeetMenuPage
