local Lines = require("leetcode-ui.component.text")
local t = require("leetcode.translator")

---@class lc-ui.Button: lc-ui.Text
local Button = Lines:extend("LeetButton")

---@class lc-ui.Button.text
---@field icon string
---@field src string

---@param text lc-ui.Button.text
---@param sc string|nil
---@param on_press function? optional
---@param expandable boolean? optional
function Button:init(text, sc, on_press, expandable)
    text.src = t(text.src)
    local opts = {
        position = "center",
        on_press = on_press or function() end,
        sc = sc,
    }
    sc = sc or ""

    Button.super.init(self, opts)

    local width = 50
    local expand = ""

    self:append(text.icon, "leetcode_list")
    self:append(" ")
    self:append(text.src)
    if expandable then self:append(" " .. expand, "leetcode_alt") end

    local len = vim.api.nvim_strwidth(self:content()) + vim.api.nvim_strwidth(sc)
    local padding = string.rep(" ", width - len)

    self:append(padding)
    self:append(sc, "leetcode_info")
end

---@type fun(): lc-ui.Button
local LeetButton = Button

return LeetButton
