local component = require("leetcode-ui.component")
local log = require("leetcode.logger")
local Line = require("nui.line")

---@class lc-ui.Button: lc-ui.Component
local button = {}
button.__index = button
setmetatable(button, component)

local function real_length(s)
    local count = 0
    local i = 1
    while i <= #s do
        local c = s:byte(i)
        if c >= 0xD800 and c <= 0xDBFF then -- Check for high surrogate
            count = count + 1
            i = i + 2 -- Skip low surrogate
        else
            count = count + 1
            i = i + 1
        end
    end
    return count
end

---@class lc-ui.Button.text
---@field icon string
---@field src string

--- @param text lc-ui.Button.text
--- @param sc string
--- @param on_press function? optional
--- @param expandable boolean? optional
--- @param keybind string? optional
--- @param keybind_opts table? optional
function button:init(text, sc, on_press, expandable, keybind, keybind_opts)
    -- local sc_ = sc:gsub("%s", ""):gsub(leader, "<leader>")
    local width = 40
    local expand = ""

    local opts = {
        position = "center",
        on_press = on_press or function() end,
    }

    local txt = text.icon .. " " .. text.src .. (expandable and " " .. expand or "")
    local padding = string.rep(" ", width - txt:len())

    local line = Line():append(txt .. padding .. sc)

    local obj = setmetatable({
        opts = opts,
        lines = { line },
    }, self)

    return obj
end

return button
