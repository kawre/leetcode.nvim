local config = require("leetcode.config")
local ui_utils = require("leetcode-ui.utils")
local utils = require("leetcode.utils")
local Picker = require("leetcode.picker")

---@class leet.Picker.Question: leet.Picker
local P = {}

P.width = 100
P.height = 20

---@param items lc.cache.Question[]
---@param opts table<string, string[]>
---
---@return lc.cache.Question[]
function P.filter(items, opts)
    if vim.tbl_isempty(opts or {}) then
        return items
    end

    ---@param q lc.cache.Question
    return vim.tbl_filter(function(q)
        local diff_flag = true
        if opts.difficulty and not vim.tbl_contains(opts.difficulty, q.difficulty:lower()) then
            diff_flag = false
        end

        local status_flag = true
        if opts.status and not vim.tbl_contains(opts.status, q.status) then
            status_flag = false
        end

        return diff_flag and status_flag
    end, items)
end

---@param content lc.cache.Question[]
---@param opts table<string, string[]>
---
---@return { entry: any, value: lc.cache.Question }[]
function P.items(content, opts)
    local filtered = P.filter(content, opts)
    return vim.tbl_map(function(item)
        return { entry = P.entry(item), value = item }
    end, filtered)
end

---@param question lc.cache.Question
local function display_user_status(question)
    if question.paid_only then
        return config.auth.is_premium and config.icons.hl.unlock or config.icons.hl.lock
    end

    return config.icons.hl.status[question.status] or { " " }
end

---@param question lc.cache.Question
local function display_difficulty(question)
    local hl = ui_utils.diff_to_hl(question.difficulty)
    return { config.icons.square, hl }
end

---@param question lc.cache.Question
local function display_question(question)
    local index = { question.frontend_id .. ".", "leetcode_normal" }
    local title = { utils.translate(question.title, question.title_cn) }
    local ac_rate = { ("(%.1f%%)"):format(question.ac_rate), "leetcode_ref" }

    return unpack({ index, title, ac_rate })
end

function P.entry(item)
    return {
        display_user_status(item),
        display_difficulty(item),
        display_question(item),
    }
end

---@param item lc.cache.Question
function P.ordinal(item)
    return ("%s. %s %s %s"):format(
        tostring(item.frontend_id),
        item.title,
        item.title_cn,
        item.title_slug
    )
end

return P
