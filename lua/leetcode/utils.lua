local config = require("leetcode.config")
local log = require("leetcode.logger")

---@class lc.Utils
local utils = {}

function utils.deprecate_usr_cmd(name, new)
    vim.api.nvim_create_user_command(name, function()
        local cmd = require("leetcode.command")
        cmd.deprecate(name, new)
        pcall(vim.cmd, new) ---@diagnostic disable-line
    end, {})
end

---@param fn string
function utils.cmd(fn)
    return ("<cmd>lua require('leetcode.command').%s()<cr>"):format(fn)
end

---@param title_slug string
---@param lang lc.lang
function utils.detect_duplicate_question(title_slug, lang)
    local tabs = utils.question_tabs()

    for _, q in ipairs(tabs) do
        if title_slug == q.question.q.title_slug and lang == q.question.lang then
            return q.tabpage
        end
    end
end

---@return { tabpage: integer, question: lc.ui.Question }[]
function utils.question_tabs()
    local questions = {}

    for _, q in ipairs(_Lc_state.questions) do
        local tabp = utils.question_tabp(q)
        if tabp then
            table.insert(questions, { tabpage = tabp, question = q })
        end
    end

    return questions
end

---@param q lc.ui.Question
---@return integer|nil
function utils.question_tabp(q)
    local ok, tabp = pcall(vim.api.nvim_win_get_tabpage, q.winid)
    if ok then
        return tabp
    end
end

---@return lc.ui.Question
function utils.curr_question()
    local tabp = vim.api.nvim_get_current_tabpage()
    local tabs = utils.question_tabs()

    local tab = vim.tbl_filter(function(tab)
        return tab.tabpage == tabp
    end, tabs)[1] or {}
    if tab.question then
        return tab.question, tabp
    else
        log.error("No current question found")
    end
end

---@return lc.language
function utils.get_lang(slug)
    ---@param l lc.language
    return vim.tbl_filter(function(l)
        return l.slug == slug
    end, config.langs)[1]
end

---@return lc.language
function utils.get_lang_by_name(name)
    ---@param l lc.language
    return vim.tbl_filter(function(l)
        return l.lang == name
    end, config.langs)[1]
end

---@param event lc.hook
---@return fun()[]|nil
function utils.get_hooks(event)
    local fns = config.user.hooks[event]
    if not fns then
        return
    end

    if type(fns) == "function" then
        fns = { fns }
    end

    return vim.list_extend(fns, config.hooks[event] or {})
end

---@param event lc.hook
function utils.exec_hooks(event, ...)
    local fns = utils.get_hooks(event)
    if not fns then
        return log.error("unknown hook event: " .. event)
    end

    for i, fn in ipairs(fns) do
        local ok, msg = pcall(fn, ...)
        if not ok then
            log.error(("bad hook #%d in `%s` event: %s"):format(i, event, msg))
        end
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

function utils.auth_guard()
    if not config.auth.is_signed_in then
        error("User not logged-in", 0)
    end
end

function utils.norm_ins(str)
    local ins = vim.inspect(str)
    return ins:sub(2, #ins - 1)
end

return utils
