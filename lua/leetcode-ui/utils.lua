local Line = require("nui.line")

local utils = {}

---@param lines NuiLine[]
function utils.longest_line(lines)
    local width = 0

    for _, line in pairs(lines) do
        local text = line:content()
        local len = vim.api.nvim_strwidth(text)
        width = math.max(len, width)
    end

    return width
end

---@param layout lc-ui.Layout
function utils.win_width(layout)
    -- local winid = vim.api.nvimbufget
    return vim.api.nvim_win_get_width(layout.winid)
end

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

---@param component lc-ui.Component
---@param layout lc-ui.Layout
---
---@return string
function utils.get_padding(component, layout)
    local position = layout.opts.position or component.opts.position
    local padding = ""

    if layout.opts.padding then
        if type(layout.opts.padding.left) == "string" then
            padding = layout.opts.padding.left --[[@as string]]
        elseif type(layout.opts.padding.left) == "number" then
            padding = string.rep(" ", layout.opts.padding.left --[[@as integer]])
        end
    end

    if component.opts.padding then
        if type(component.opts.padding.left) == "string" then
            padding = padding .. layout.opts.padding.left --[[@as string]]
        elseif type(component.opts.padding.left) == "number" then
            padding = padding .. string.rep(" ", component.opts.padding.left --[[@as integer]])
        end
    end

    if position ~= "left" then
        local lines = component.lines
        local longest_line = utils.longest_line(lines)

        if position == "center" then
            local width = utils.win_width(layout)
            local mid = (width - longest_line) / 2
            local spaces = string.rep(" ", mid)
            padding = spaces
        elseif position == "right" then
            local width = utils.win_width(layout)
            local mid = width - longest_line - 1
            local spaces = string.rep(" ", mid)
            padding = spaces
        end
    end

    return padding
end

return utils
