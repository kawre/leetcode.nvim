local Line = require("nui.line")
local log = require("leetcode.logger")

local utils = {}

---@param lines lc-ui.Lines
function utils.longest_line(lines)
    local width = 0

    for _, line in pairs(lines:contents()) do
        local len = vim.api.nvim_strwidth(line:content())
        width = math.max(len, width)
    end

    return width
end

---@param layout lc-ui.Layout
function utils.win_width(layout)
    -- local winid = vim.api.nvimbufget
    return vim.api.nvim_win_get_width(layout._.opts.winid)
end

--@param config lc-ui.Component.config
---
---@return NuiLine[]
function utils.parse_lines(lines, opts)
    local tbl = {}

    if type(lines) == "table" then
        for _, line in pairs(lines) do
            if type(line) == "string" then
                local nui_line = Line()
                nui_line:append(line, opts and opts.hl or nil)
                table.insert(tbl, nui_line)
            else
                table.insert(tbl, line)
            end
        end
    end

    return tbl
end

---@param lines lc-ui.Lines
---@param layout lc-ui.Layout
---
---@return string
function utils.get_padding(lines, layout)
    local position = layout._.opts.position or lines.opts.position
    local padding = ""

    if layout._.opts.padding then
        if type(layout._.opts.padding.left) == "string" then
            padding = layout._.opts.padding.left --[[@as string]]
        elseif type(layout._.opts.padding.left) == "number" then
            padding = string.rep(" ", layout._.opts.padding.left --[[@as integer]])
        end
    end

    if lines.opts.padding then
        if type(lines.opts.padding.left) == "string" then
            padding = padding .. layout._.opts.padding.left --[[@as string]]
        elseif type(lines.opts.padding.left) == "number" then
            padding = padding .. string.rep(" ", lines.opts.padding.left --[[@as integer]])
        end
    end

    if position ~= "left" then
        local max_len = utils.longest_line(lines)

        if position == "center" then
            local width = utils.win_width(layout)
            local mid = (width - max_len) / 2
            local spaces = string.rep(" ", mid)
            padding = spaces
        elseif position == "right" then
            local width = utils.win_width(layout)
            local mid = width - max_len - 1
            local spaces = string.rep(" ", mid)
            padding = spaces
        end
    end

    return padding
end

return utils
