local config = require("leetcode.config")

---@class lc.Utils
local utils = {}

---@param name string
---@param command any
---@param opts table|nil
function utils.create_usr_cmd(name, command, opts)
    vim.api.nvim_create_user_command(name, command, opts or {})
end

function utils.deprecate_usr_cmd(name, new)
    vim.api.nvim_create_user_command(name, function()
        local cmd = require("leetcode.command")
        cmd.deprecate(name, new)
        pcall(vim.cmd, new) ---@diagnostic disable-line
    end, {})
end

function utils.remove_cookie() --
    require("leetcode.cache.cookie").delete()
end

function utils.alpha_move_cursor_top()
    local curr_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_cursor(curr_win, { 1, 0 })
    require("alpha").move_cursor(curr_win)
end

---Extracts an HTML tag from a string.
---
---@param str string The input string containing HTML tags.
---@return string | nil The extracted HTML tag, or nil if no tag is found.
function utils.get_html_tag(str) return str:match("^<(.-)>") end

---@param str string
---@param tag string
---
---@return string
function utils.strip_html_tag(str, tag)
    local regex = string.format("^<%s>(.*)</%s>$", tag, tag)
    assert(str:match(regex))

    local offset = 3 + tag:len()
    return str:sub(offset, str:len() - offset)
end

---@param fn string
function utils.cmd(fn) return string.format("<cmd>lua require('leetcode.command').%s()<cr>", fn) end

---map a key in mode
---@param mode string | "'n'" | "'v'" | "'x'" | "'s'" | "'o'" | "'!'" | "'i'" | "'l'" | "'c'" | "'t'" | "''"
---@param lhs string
---@param rhs string
---@param opts? {silent: boolean, expr: boolean}
function utils.map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then options = vim.tbl_extend("force", options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

---@param title_slug string
---@param lang lc.lang
function utils.detect_duplicate_question(title_slug, lang)
    local tabs = utils.curr_question_tabs()

    for _, q in ipairs(tabs) do
        if title_slug == q.question.q.title_slug and lang == q.question.lang then
            return q.tabpage
        end
    end
end

---@return { tabpage: integer, question: lc-ui.Question }[]
function utils.curr_question_tabs()
    local questions = {}

    for _, q in ipairs(_Lc_questions) do
        local tabp = utils.question_tabp(q)
        if tabp then table.insert(questions, { tabpage = tabp, question = q }) end
    end

    return questions
end

---@param q lc-ui.Question
---@return integer|nil
function utils.question_tabp(q)
    local ok, tabp = pcall(vim.api.nvim_win_get_tabpage, q.winid)
    if ok then return tabp end
end

---@return lc-ui.Question
function utils.curr_question()
    local tabp = vim.api.nvim_get_current_tabpage()
    local tabs = utils.curr_question_tabs()

    local tab = vim.tbl_filter(function(tab) return tab.tabpage == tabp end, tabs)[1] or {}
    if tab.question then
        return tab.question, tabp
    else
        local log = require("leetcode.logger")
        log.error("No current question found")
    end
end

---@return lc.language
function utils.get_lang(slug)
    return vim.tbl_filter(function(l) return l.slug == slug end, config.langs)[1]
end

---@param event lc.hook
function utils.exec_hooks(event, ...)
    local log = require("leetcode.logger")
    local fns = config.user.hooks[event]
    if not fns then log.error("unknown hook event: " .. event) end

    for i, fn in ipairs(fns) do
        local ok, msg = pcall(fn, ...)
        if not ok then log.error(("bad hook #%d in `%s` event: %s"):format(i, event, msg)) end
    end
end

---@param content string
---@param translated_content string
function utils.translate(content, translated_content)
    if config.is_cn then
        if config.user.cn.translate_problems then
            return translated_content or content
        else
            return content or translated_content
        end
    else
        return content
    end
end

function utils.auth_guard() assert(config.auth.is_signed_in, "User not logged-in") end

return utils
