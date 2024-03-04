local O = require("nui.object")
local log = require("leetcode.logger")
local config = require("leetcode.config")

---@class lc-ui.Utils
local utils = {}

---@param tbl table
function utils.shallowcopy(tbl)
    local new_tbl = {}
    for _, value in ipairs(tbl) do
        table.insert(new_tbl, value)
    end

    return new_tbl
end

---@param item lc.ui.Lines
function utils.longest_line(item)
    if item.class.name == "LeetLine" then
        return vim.api.nvim_strwidth(item:content())
    end

    local max_len = 0
    for _, line in pairs(item:contents()) do
        max_len = math.max(utils.longest_line(line), max_len)
    end

    return max_len
end

---@param diff string
function utils.diff_to_hl(diff)
    local hl = {
        all = "leetcode_all",

        easy = "leetcode_easy",
        fundamental = "leetcode_easy",

        medium = "leetcode_medium",
        intermediate = "leetcode_medium",

        hard = "leetcode_hard",
        advanced = "leetcode_hard",
    }

    return hl[diff:lower()] or ""
end

---@param status string
function utils.status_to_hl(status)
    if not status then
        return
    end

    return table.unpack(config.icons.hl.status[status])
end

---@param layout lc.ui.Renderer
function utils.win_width(layout)
    if not (layout.winid and vim.api.nvim_win_is_valid(layout.winid)) then
        return 0
    end
    return vim.api.nvim_win_get_width(layout.winid)
end

---@param lines lc.ui.Lines
---@param layout lc.ui.Renderer
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
    if position ~= "left" and vim.api.nvim_win_is_valid(layout.winid or -1) then
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
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    for opt, value in pairs(options) do
        local ok, err = pcall(vim.api.nvim_set_option_value, opt, value, { buf = bufnr })
        if not ok then
            log.error(err)
        end
    end
end

function utils.set_win_opts(winid, options)
    if not vim.api.nvim_win_is_valid(winid) then
        return
    end

    for opt, value in pairs(options) do
        local ok, err =
            pcall(vim.api.nvim_set_option_value, opt, value, { win = winid, scope = "local" })
        if not ok then
            log.error(err)
        end
    end
end

function utils.is_instance(instance, class)
    return type(instance) == "table" and O.is_instance(instance, class)
end

return utils
