local Line = require("nui.line")
local log = require("leetcode.logger")

---@class lc-ui.Utils
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

---@param layout lc-ui.Renderer
function utils.win_width(layout)
    if not vim.api.nvim_win_is_valid(layout.winid) then return 0 end
    return vim.api.nvim_win_get_width(layout.winid)
end

---@param lines lc-ui.Lines
---@param layout lc-ui.Renderer
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

function utils.set_buf_opts(bufnr, options)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end

    for opt, value in pairs(options) do
        local ok, err = pcall(vim.api.nvim_set_option_value, opt, value, { buf = bufnr })
        if not ok then log.error(err) end
    end
end

function utils.set_win_opts(winid, options)
    if not vim.api.nvim_win_is_valid(winid) then return end

    for opt, value in pairs(options) do
        local ok, err =
            pcall(vim.api.nvim_set_option_value, opt, value, { win = winid, scope = "local" })
        if not ok then log.error(err) end
    end
end

return utils
