local Lines = require("leetcode-ui.lines")
local config = require("leetcode.config")
local t = require("leetcode.translator")

---@class lc-menu.Footer : lc.ui.Lines
local Footer = Lines:extend("LeetFooter")

function Footer:draw(layout, opts)
    if config.auth.is_signed_in then
        self:clear()
        self:append(t("Signed in as") .. ": ", "leetcode_alt")
        self:append(config.auth.name):endl()
    end

    Footer.super.draw(self, layout, opts)
end

---@param opts? any
function Footer:init(opts)
    opts = vim.tbl_deep_extend("force", {
        hl = "Number",
    }, opts or {})

    Footer.super.init(self, {}, opts)
end

---@type fun(): lc-menu.Footer
local LeetFooter = Footer

return LeetFooter
