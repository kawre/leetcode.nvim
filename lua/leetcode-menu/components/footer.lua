local Lines = require("leetcode-ui.component.text")
local config = require("leetcode.config")
local t = require("leetcode.translator")

---@class lc-menu.Footer : lc-ui.Text
local Footer = Lines:extend("LeetFooter")

function Footer:draw(layout)
    if config.auth.is_signed_in then
        self:append(t("Signed in as") .. ": ", "leetcode_alt")
        self:append(config.auth.name)
    end

    Footer.super.draw(self, layout)
end

---@param opts? any
function Footer:init(opts)
    opts = vim.tbl_deep_extend("force", {
        position = "center",
        hl = "Number",
    }, opts or {})

    Footer.super.init(self, opts)

    -- self:draw()
end

local LeetFooter = Footer

return LeetFooter
