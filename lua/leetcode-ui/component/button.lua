local component = require("leetcode-ui.component")
local NuiLine = require("nui.line")

---@class lc-ui.Button: lc-ui.Component
local button = {}
button.__index = button
setmetatable(button, component)

---@class lc-ui.Button.text
---@field icon string
---@field src string

---@param text lc-ui.Button.text
---@param sc string|nil
---@param on_press function? optional
---@param expandable boolean? optional
function button:init(text, sc, on_press, expandable)
    local opts = {
        position = "center",
        on_press = on_press or function() end,
        sc = sc,
    }
    sc = sc or ""

    local width = 50
    local expand = ""

    local text_line = NuiLine()
    text_line:append(text.icon, "leetcode_list")
    text_line:append(" ")
    text_line:append(text.src)
    if expandable then text_line:append(" " .. expand, "leetcode_alt") end

    local len = vim.api.nvim_strwidth(text_line:content()) + vim.api.nvim_strwidth(sc)
    local padding = string.rep(" ", width - len)

    text_line:append(padding)
    text_line:append(sc, "leetcode_info")

    self = setmetatable({
        opts = opts,
        lines = { text_line },
    }, self)

    return self
end

return button
