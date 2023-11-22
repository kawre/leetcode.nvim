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
    if not vim.api.nvim_win_is_valid(layout.winid) then return 0 end
    return vim.api.nvim_win_get_width(layout.winid)
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
    local opts = lines._.opts
    local padding = ""

    -- if type(opts.padding.left) == "string" then
    --     padding = opts.padding.left
    -- elseif type(opts.padding.left) == "number" then
    --     padding = (" "):rep(opts.padding.left)
    -- end

    if type(opts.padding.left) == "string" then
        padding = padding .. opts.padding.left
    elseif type(opts.padding.left) == "number" then
        padding = padding .. (" "):rep(opts.padding.left)
    end

    local position = opts.position
    if position ~= "left" and vim.api.nvim_win_is_valid(layout.winid) then
        local max_len = utils.longest_line(lines)
        local win_width = utils.win_width(layout)

        if position == "center" then
            local mid = (win_width - max_len) / 2
            local spaces = (" "):rep(mid)
            padding = spaces
        elseif position == "right" then
            local mid = win_width - max_len - 1
            local spaces = (" "):rep(mid)
            padding = spaces
        end
    end

    return padding
end

return utils
