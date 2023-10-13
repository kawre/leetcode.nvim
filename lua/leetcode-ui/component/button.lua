local component = require("leetcode-ui.component")
local NuiLine = require("nui.line")

---@class lc-ui.Button: lc-ui.Component
local button = {}
button.__index = button
setmetatable(button, component)

---@class lc-ui.Button.text
---@field icon string
---@field src string

--- @param text lc-ui.Button.text
--- @param sc string|nil
--- @param on_press function? optional
--- @param expandable boolean? optional
function button:init(text, sc, on_press, expandable)
    local opts = {
        position = "center",
        on_press = on_press or function() end,
        sc = sc,
    }
    sc = sc and "" or ""

    local width = 50
    local expand = ""

    local txt = text.icon .. " " .. text.src .. " " .. (expandable and expand or "")
    local len = vim.api.nvim_strwidth(txt) + vim.api.nvim_strwidth(sc)
    local padding = string.rep(" ", width - len)

    local line = NuiLine()
    line:append(txt)
    line:append(padding)
    line:append(sc, "leetcode_info")

    local obj = setmetatable({
        opts = opts,
        lines = { line },
    }, self)

    return obj
end

return button
