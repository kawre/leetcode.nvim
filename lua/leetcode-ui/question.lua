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
---@field reset boolean
local Question = Object("LeetQuestion")

---@param raw? boolean
function Question:snippet(raw)
    local snippets = self.q.code_snippets ~= vim.NIL and self.q.code_snippets or {}
    local snip = vim.tbl_filter(function(snip)
        return snip.lang_slug == self.lang
    end, snippets)[1]
    if not snip then
        return
    end

    local code = snip.code:gsub("\r\n", "\n")
    return raw and code or self:injector(code)
end

---@param code? string
function Question:set_lines(code)
    if not (self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr)) then
        return
    end

    pcall(vim.cmd.undojoin)
    local s_i, e_i, lines = self:range()
    s_i = s_i or 1
    e_i = e_i or #lines
    code = code and code or (self:snippet(true) or "")
    vim.api.nvim_buf_set_lines(self.bufnr, s_i - 1, e_i, false, vim.split(code, "\n"))
end

function Question:reset_lines()
    local new_lines = self:snippet(true) or ""

    vim.schedule(function() --
        log.info("Previous code found and reset\nTo undo, simply press `u`")
    end)

    self:set_lines(new_lines)
end

---@return string path, boolean existed
function Question:path()
    local lang = utils.get_lang(self.lang)
    local alt = lang.alt and ("." .. lang.alt) or ""

    -- handle legacy file names first
    local fn_legacy = --
        ("%s.%s-%s.%s"):format(self.q.frontend_id, self.q.title_slug, lang.slug, lang.ft)
    self.file = config.storage.home:joinpath(fn_legacy)

    if self.file:exists() then
        return self.file:absolute(), true
    end

    local fn = ("%s.%s%s.%s"):format(self.q.frontend_id, self.q.title_slug, alt, lang.ft)
    self.file = config.storage.home:joinpath(fn)
    local existed = self.file:exists()

    if not existed then
        self.file:write(self:snippet(), "w")
    end

    return self.file:absolute(), existed
end

function Question:create_buffer()
    local path, existed = self:path()

    vim.cmd("$tabe " .. path)
    self.bufnr = vim.api.nvim_get_current_buf()
    self.winid = vim.api.nvim_get_current_win()

    self:open_buffer(existed)
end

---@param existed boolean
function Question:open_buffer(existed)
    vim.api.nvim_win_set_buf(self.winid, self.bufnr)
    vim.api.nvim_set_option_value("buflisted", true, { buf = self.bufnr })
    vim.api.nvim_set_option_value("winfixbuf", true, { win = self.winid })

    local i = self:fold_range()
    if i then
        pcall(vim.cmd, ("%d,%dfold"):format(1, i))
    end

    if existed and self.cache.status == "ac" then
        self:reset_lines()
    end
end

---@param before boolean
function Question:inject(before)
    local inject = config.user.injector[self.lang] or {}
    local inj = before and inject.before or inject.after

    local res

    if type(inj) == "boolean" and inj == true and before then
        inj = config.imports[self.lang]
    end

    if type(inj) == "table" then
        res = table.concat(inj, "\n")
    elseif type(inj) == "string" then
        res = inj
    end

    if res and res ~= "" then
        return before and (res .. "\n") or ("\n" .. res)
    else
        return nil
    end
end

---@param code string
function Question:injector(code)
    local lang = utils.get_lang(self.lang)

    local parts = {
        ("%s @leet start"):format(lang.comment),
        code,
        ("%s @leet end"):format(lang.comment),
    }

    local before = self:inject(true)
    if before then
        table.insert(parts, 1, before)
    end

    local after = self:inject(false)
    if after then
        table.insert(parts, after)
    end

    return table.concat(parts, "\n")
end

function Question:_unmount()
    if vim.v.dying ~= 0 then
        return
    end

    vim.schedule(function()
        self.info:unmount()
        self.console:unmount()
        self.description:unmount()

        if self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) then
            vim.api.nvim_buf_delete(self.bufnr, { force = true, unload = false })
        end

        _Lc_state.questions = vim.tbl_filter(function(q)
            return q.bufnr ~= self.bufnr
        end, _Lc_state.questions)

        self = nil
    end)
end

function Question:unmount()
    if self.winid and vim.api.nvim_win_is_valid(self.winid) then
        vim.api.nvim_win_close(self.winid, true)
    end
end

local group = vim.api.nvim_create_augroup("leetcode_questions", { clear = true })
function Question:autocmds()
    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        pattern = tostring(self.winid),
        callback = function()
            self:_unmount()
        end,
    })
end

function Question:handle_mount()
    self:create_buffer()

    self.description = Description(self):mount()
    self.console = Console(self)
    self.info = Info(self)

    table.insert(_Lc_state.questions, self)

    self:autocmds()
    utils.exec_hooks("question_enter", self)

    return self
end

function Question:mount()
    local tabp = utils.detect_duplicate_question(self.cache.title_slug, config.lang)
    if tabp then
        return pcall(vim.api.nvim_set_current_tabpage, tabp)
    end

    local q = api_question.by_title_slug(self.cache.title_slug)
    if not q or q.is_paid_only and not config.auth.is_premium then
        return log.warn("Question is for premium users only")
    end
    self.q = q

    if self:snippet() then
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
    if start_i == nil or start_i <= 1 then
        return
    end

    local i = start_i - 1
    while lines[i] == "" do
        i = i - 1
    end

    if 1 < i then
        return i
    end
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
    local old_lang, old_bufnr = self.lang, self.bufnr

    local ok, err = pcall(function()
        self.lang = lang
        local path, existed = self:path()

        self.bufnr = vim.fn.bufadd(path)
        assert(self.bufnr ~= 0, "Failed to create buffer " .. path)

        local loaded = vim.api.nvim_buf_is_loaded(self.bufnr)
        vim.fn.bufload(self.bufnr)

        vim.api.nvim_set_option_value("buflisted", false, { buf = old_bufnr })
        self:open_buffer(existed)

        if not loaded then
            utils.exec_hooks("question_enter", self)
        end
    end)

    if not ok then
        log.error("Failed to change language\n" .. err)
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
