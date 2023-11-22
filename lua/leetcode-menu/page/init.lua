local Layout = require("leetcode-ui.layout")

---@class lc-menu.Page : lc-ui.Layout
local Page = Layout:extend("LeetMenuPage")

function Page:init(components, opts) --
    local options = vim.tbl_deep_extend("force", {
        position = "center",
    }, opts or {})

    Page.super.init(self, components or {}, options)
end

---@type fun(): lc-menu.Page
local LeetMenuPage = Page

return LeetMenuPage
