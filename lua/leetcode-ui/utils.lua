local Line = require("nui.line")
local log = require("leetcode.logger")

local utils = {}

---@param lines NuiLine[]
function utils.longest_line(lines)
    local width = 0

    for _, line in pairs(lines) do
        local text = line:content()
        width = math.max(text:len(), width)
    end

    return width
end

---@param split NuiSplit
function utils.win_width(split) return vim.api.nvim_win_get_width(split.winid) end

---@param config lc-ui.Component.config
---
---@return NuiLine[]
function utils.parse_lines(config)
    local lines = config.lines
    local t = {}

    if type(lines) == "table" then
        for _, line in pairs(lines) do
            if type(line) == "string" then
                local nui_line = Line()
                nui_line:append(line, config.opts and config.opts.hl or nil)
                table.insert(t, nui_line)
            else
                table.insert(t, line)
            end
        end
    end

    return t
end

---@param lines NuiLine[]
---@param position position
---@param split NuiSplit | NuiSplit
---
---@return string
function utils.get_padding(lines, position, split)
    local padding = ""

    if position ~= "left" then
        local longest_line = utils.longest_line(lines)

        if position == "center" then
            local width = utils.win_width(split)
            local mid = (width - longest_line) / 2
            local spaces = string.rep(" ", mid - 1)
            padding = spaces
        elseif position == "right" then
            local width = utils.win_width(split)
            local mid = width - longest_line - 1
            local spaces = string.rep(" ", mid - 1)
            padding = spaces
        end
    end

    return padding
end

return utils
