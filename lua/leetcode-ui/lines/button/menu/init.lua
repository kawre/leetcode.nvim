local Button = require("leetcode-ui.lines.button")
local t = require("leetcode.translator")

local log = require("leetcode.logger")

---@class lc.ui.Button.Menu : lc.ui.Button
local MenuButton = Button:extend("LeetMenuButton")

---@alias lc.ui.Button.Menu.opts
---| { expandable?: boolean, expand_icon?: string, icon: string, width?: integer }
---| lc.ui.Button.opts

---@param text string
---@param opts lc.ui.Button.Menu.opts
function MenuButton:init(text, opts)
    text = t(text)
    opts = vim.tbl_deep_extend("force", {
        expandable = false,
        expand_icon = "",
        width = 50,
    }, opts or {})
    MenuButton.super.init(self, {}, opts)

    self:append(opts.icon, "leetcode_list")
    self:append(" ")
    self:append(text)

    if opts.expandable then
        self:append(" " .. opts.expand_icon, "leetcode_alt")
    end

    local len = vim.api.nvim_strwidth(self:content()) + vim.api.nvim_strwidth(opts.sc or "")
    local padding = (" "):rep(opts.width - len)

    self:append(padding)
    if opts.sc then
        self:append(opts.sc, "leetcode_info")
    end
end

---@type fun(text: string, opts: lc.ui.Button.Menu.opts): lc.ui.Button
local LeetMenuButton = MenuButton

return LeetMenuButton
