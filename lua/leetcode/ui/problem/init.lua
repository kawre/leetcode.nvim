local Description = require("leetcode.ui.problem.description")
local Info = require("leetcode.ui.problem.info")
local Console = require("leetcode-ui.layout.console")
local Window = require("leetcode.ui.problem.window")
local markup = require("markup")

local api_question = require("leetcode.api.question")
local utils = require("leetcode.utils")
local ui_utils = require("leetcode-ui.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")

---@class leet.ui.Problem : markup.TabPage
---@field protected super markup.TabPage
---@field file Path
---@field q lc.question_res
---@field description lc.ui.Description
---@field bufnr integer
---@field console lc.ui.Console
---@field lang string
---@field cache lc.cache.Question
---@field reset boolean
---@field win leet.ui.Problem.Window
local Problem = markup.TabPage:extend("leet.question")

---@param raw? boolean
function Problem:snippet(raw)
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

---@return string path, boolean existed
function Problem:path()
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

---@param before boolean
function Problem:inject(before)
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
function Problem:injector(code)
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

function Problem:_unmount()
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

function Problem:unmount()
    if self.winid and vim.api.nvim_win_is_valid(self.winid) then
        vim.api.nvim_win_close(self.winid, true)
    end
end

local group = vim.api.nvim_create_augroup("leetcode_questions", { clear = true })
function Problem:autocmds()
    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        pattern = tostring(self.winid),
        callback = function()
            self:_unmount()
        end,
    })
end

function Problem:handle_mount()
    local path, existed = self:path()

    self:set_file(path)
    Problem.super.mount(self)

    self.win = Window({
        problem = self,
        minimal = false,
        bufnr = 0,
        winid = 0,
        buf_opts = {
            buflisted = true,
        },
    })

    -- self:open_buffer(existed)

    self.description = Description(self)
    -- self.console = Console(self)
    self.info = Info(self)

    table.insert(_Lc_state.questions, self)

    -- self:autocmds()
    -- utils.exec_hook("question_enter", self)

    return self
end

function Problem:mount()
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

---@param self lc.ui.Question
---@param lang lc.lang
Problem.change_lang = vim.schedule_wrap(function(self, lang)
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
            utils.exec_hook("question_enter", self)
        end
    end)

    if not ok then
        log.error("Failed to change language\n" .. err)
        self.lang = old_lang
        self.bufnr = old_bufnr
    end
end)

---@param problem lc.cache.Question
function Problem:init(problem)
    self.cache = problem
    self.lang = config.lang

    Problem.super.init(self, {
        mount = true,
    })
end

---@type fun(question: lc.cache.Question): leet.ui.Problem
local LeetProblem = Problem

return LeetProblem
