local Description = require("leetcode-ui.split.description")
local Console = require("leetcode-ui.layout.console")
local Info = require("leetcode-ui.popup.info")
local Object = require("nui.object")

local api_question = require("leetcode.api.question")
local utils = require("leetcode.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")

---@class lc.ui.Question
---@field file Path
---@field q lc.question_res
---@field description lc.ui.Description
---@field bufnr integer
---@field console lc.ui.Console
---@field lang string
---@field cache lc.cache.Question
local Question = Object("LeetQuestion")

---@param raw? boolean
function Question:get_snippet(raw)
    local snippets = self.q.code_snippets ~= vim.NIL and self.q.code_snippets or {}
    local snip = vim.tbl_filter(function(snip) return snip.lang_slug == self.lang end, snippets)[1]
    if not snip then return end

    local code = snip.code:gsub("\r\n", "\n")
    return raw and code or self:injector(code)
end

function Question:create_file()
    local lang = utils.get_lang(self.lang)
    local alt = lang.alt and ("." .. lang.alt) or ""

    -- handle legacy file names first
    local fn_legacy = --
        ("%s.%s-%s.%s"):format(self.q.frontend_id, self.q.title_slug, lang.slug, lang.ft)
    self.file = config.storage.home:joinpath(fn_legacy)

    if self.file:exists() then --
        return self.file:absolute()
    end

    local fn = ("%s.%s%s.%s"):format(self.q.frontend_id, self.q.title_slug, alt, lang.ft)
    self.file = config.storage.home:joinpath(fn)

    if not self.file:exists() then --
        self.file:write(self:get_snippet(), "w")
    end

    return self.file:absolute()
end

---@param new_tabp? boolean
---@return boolean was_loaded
function Question:create_buffer(new_tabp)
    local file_name = self:create_file()

    local buf = vim.fn.bufadd(file_name)
    assert(buf ~= 0, "Failed to create buffer")

    self.bufnr = buf
    if vim.fn.bufloaded(self.bufnr) == 1 then
        return true
    else
        vim.fn.bufload(self.bufnr)
    end

    local cmd
    if new_tabp then
        cmd = ("$tabe %s"):format(file_name)
    else
        cmd = ("edit %s"):format(file_name)
    end

    local i = self:fold_range()
    if i then cmd = cmd .. (" | %d,%dfold"):format(1, i) end

    vim.api.nvim_exec2(cmd, {})

    return false
end

---@param before boolean
function Question:inject(before)
    local inject = config.user.injector[self.lang] or {}
    local inj = before and inject.before or inject.after

    local res

    if type(inj) == "boolean" and inj == true and before then --
        inj = config.imports[self.lang]
    end

    if type(inj) == "table" then
        res = table.concat(inj, "\n")
    elseif type(inj) == "string" then
        res = inj
    end

    if res and res ~= "" then
        return before and (res .. "\n\n") or ("\n\n" .. res)
    else
        return nil
    end
end

---@param code string
function Question:injector(code)
    local lang = utils.get_lang(self.lang)

    local inj_before = self:inject(true) or ""
    local inj_after = self:inject(false) or ""

    return inj_before --
        .. ("%s @leet start\n"):format(lang.comment)
        .. code
        .. ("\n%s @leet end"):format(lang.comment)
        .. inj_after
end

---@param pre? boolean
function Question:_unmount(pre)
    self.info:unmount()
    self.console:unmount()
    self.description:unmount()

    if not pre and vim.api.nvim_buf_is_valid(self.bufnr) then
        vim.api.nvim_buf_delete(self.bufnr, { force = true })
    end

    if vim.api.nvim_win_is_valid(self.winid) then --
        vim.api.nvim_win_close(self.winid, true)
    end

    _Lc_questions = vim.tbl_filter(function(q) return q.bufnr ~= self.bufnr end, _Lc_questions)

    self = nil
end

---@param self lc.ui.Question
---@param pre? boolean
Question.unmount = vim.schedule_wrap(function(self, pre) self:_unmount(pre) end)

function Question:handle_mount()
    self:create_buffer(true)

    self.winid = vim.api.nvim_get_current_win()

    table.insert(_Lc_questions, self)

    vim.api.nvim_create_autocmd("QuitPre", {
        buffer = self.bufnr,
        callback = function() self:unmount(true) end,
    })

    self.description = Description(self):mount()
    self.console = Console(self)
    self.info = Info(self)

    utils.exec_hook("question_enter", self)

    return self
end

function Question:mount()
    local tabp = utils.detect_duplicate_question(self.cache.title_slug, config.lang)
    if tabp then return pcall(vim.api.nvim_set_current_tabpage, tabp) end

    local q = api_question.by_title_slug(self.cache.title_slug)
    if not q or q.is_paid_only and not config.auth.is_premium then
        return log.warn("Question is for premium users only")
    end
    self.q = q

    if self:get_snippet() then
        self:handle_mount()
    else
        local msg = ("Snippet for `%s` not found. Select a different language"):format(self.lang)
        log.warn(msg)

        require("leetcode.pickers.language").pick_lang(self, function(snippet)
            self.lang = snippet.t.slug
            self:handle_mount()
        end)
    end

    return self
end

---@param inclusive? boolean
---@return integer, integer, string[]
function Question:range(inclusive)
    local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
    local start_i, end_i

    for i, line in ipairs(lines) do
        if line:match("@leet start") then
            start_i = i + (inclusive and 0 or 1)
        elseif line:match("@leet end") then
            end_i = i - (inclusive and 0 or 1)
        end
    end

    return start_i, end_i, lines
end

function Question:fold_range()
    local start_i, _, lines = self:range(true)
    if start_i == nil or start_i <= 1 then return end

    local i = start_i - 1
    while lines[i] == "" do
        i = i - 1
    end

    if 1 < i then return i end
end

---@param submit boolean
---@return string
function Question:lines(submit)
    local start_i, end_i, lines = self:range()

    start_i = start_i or 1
    end_i = end_i or #lines

    local prefix = not submit and ("\n"):rep(start_i - 1) or ""
    return prefix .. table.concat(lines, "\n", start_i, end_i)
end

---@param self lc.ui.Question
---@param lang lc.lang
Question.change_lang = vim.schedule_wrap(function(self, lang)
    if vim.api.nvim_get_current_win() ~= self.winid then
        vim.api.nvim_set_current_win(self.winid)
    end

    local old_lang, old_bufnr = self.lang, self.bufnr
    self.lang = lang

    local ok, was_loaded = pcall(Question.create_buffer, self)
    if ok then
        vim.api.nvim_buf_set_option(old_bufnr, "buflisted", false)
        vim.api.nvim_buf_set_option(self.bufnr, "buflisted", true)

        if was_loaded then
            vim.api.nvim_win_set_buf(self.winid, self.bufnr)
        else
            utils.exec_hook("question_enter", self)
        end
    else
        log.error("Changing language failed")
        self.lang = old_lang
        self.bufnr = old_bufnr
    end
end)

---@param problem lc.cache.Question
function Question:init(problem)
    self.cache = problem
    self.lang = config.lang
end

---@type fun(question: lc.cache.Question): lc.ui.Question
local LeetQuestion = Question

return LeetQuestion
