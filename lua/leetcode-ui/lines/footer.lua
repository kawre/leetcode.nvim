local t = require("leetcode.translator")
local Group = require("leetcode-ui.group")

local config = require("leetcode.config")
local stats = require("leetcode-ui.lines.stats")

---@class lc.ui.menu.Footer : lc.ui.Group
local Footer = Group:extend("LeetFooter")

function Footer:contents()
    self:clear()

    if config.auth.is_signed_in then
        self:append(stats)
        self:endgrp()

        self:append(t("Signed in as") .. ": ", "leetcode_alt")
        if config.auth.is_premium then
            self:append(config.icons.star .. " ", "leetcode_medium")
        end
        self:append(config.auth.name):endl()
    end

    return Footer.super.contents(self)
end

---@param opts? any
function Footer:init(opts)
    opts = vim.tbl_deep_extend("force", {
        hl = "Number",
        spacing = 1,
    }, opts or {})

    Footer.super.init(self, {}, opts)
end

---@type fun(): lc.ui.menu.Footer
local LeetFooter = Footer

return LeetFooter()
