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

function Question:get_snippet()
    local snippets = self.q.code_snippets ~= vim.NIL and self.q.code_snippets or {}
    local snip = vim.tbl_filter(function(snip) return snip.lang_slug == self.lang end, snippets)[1]
    if not snip then return end

    return self:injector(snip.code or "")
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

---@param code string
function Question:injector(code)
    code = code:gsub("\r\n", "\n")

    local injector = config.user.injector

    local inject = injector[self.lang]
    if not inject or vim.tbl_isempty(inject) then return code end

    ---@param inj? string|string[]
    ---@param before boolean
    local function norm_inject(inj, before)
        local res

        if type(inj) == "table" then
            res = table.concat(inj, "\n")
        elseif type(inj) == "string" then
            res = inj
        end

        if res and res ~= "" then
            return before and (res .. "\n\n") or ("\n\n" .. res)
        else
            return ""
        end
    end

    local lang = utils.get_lang(self.lang)
    return norm_inject(inject.before, true) --
        .. ("%s @leet start\n"):format(lang.comment)
        .. code
        .. ("\n%s @leet end"):format(lang.comment)
        .. norm_inject(inject.after, false)
end

function Question:_unmount()
    self.info:unmount()
    self.console:unmount()
    self.description:unmount()

    if vim.api.nvim_buf_is_valid(self.bufnr) then
        pcall(vim.api.nvim_buf_delete, self.bufnr, { force = true })
    end

    if vim.api.nvim_win_is_valid(self.winid) then --
        pcall(vim.api.nvim_win_close, self.winid, true)
    end

    _Lc_questions = vim.tbl_filter(function(q) return q.bufnr ~= self.bufnr end, _Lc_questions)

    self = nil
end

---@param self lc.ui.Question
Question.unmount = vim.schedule_wrap(function(self) self:_unmount() end)

function Question:handle_mount()
    vim.cmd("$tabe " .. self:create_file())

    -- https://github.com/kawre/leetcode.nvim/issues/14
    if self.lang == "rust" then
        pcall(function() require("rust-tools.standalone").start_standalone_client() end)
    end

    self.bufnr = vim.api.nvim_get_current_buf()
    self.winid = vim.api.nvim_get_current_win()
    table.insert(_Lc_questions, self)

    vim.api.nvim_create_autocmd("QuitPre", {
        buffer = self.bufnr,
        callback = function() self:unmount() end,
    })

    self.description = Description(self):mount()
    self.console = Console(self)
    self.info = Info(self)

    utils.exec_hooks("LeetQuestionNew", self)

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

---@return integer, integer, string[]
function Question:range()
    local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
    local start_i, end_i = 1, #lines

    for i, line in ipairs(lines) do
        if line:match("@leet start") then
            start_i = i + 1
        elseif line:match("@leet end") then
            end_i = i - 1
        end
    end

    return start_i, end_i, lines
end

---@param submit boolean
---@return string
function Question:lines(submit)
    local start_i, end_i, lines = self:range()
    local prefix = not submit and ("\n"):rep(start_i - 1) or ""
    return prefix .. table.concat(lines, "\n", start_i, end_i)
end

---@param self lc.ui.Question
---@param lang lc.lang
Question.change_lang = vim.schedule_wrap(function(self, lang)
    local old_lang = self.lang
    self.lang = lang

    local new_bufnr = vim.fn.bufadd(self:create_file())
    if new_bufnr ~= 0 then
        local bufloaded = vim.fn.bufloaded(new_bufnr)

        vim.api.nvim_win_set_buf(self.winid, new_bufnr)

        vim.api.nvim_buf_set_option(self.bufnr, "buflisted", false)
        vim.api.nvim_buf_set_option(new_bufnr, "buflisted", true)

        self.bufnr = new_bufnr
        if bufloaded == 0 then --
            utils.exec_hooks("LeetQuestionNew", self)
        end
    else
        log.error("Changing language failed")
        self.lang = old_lang
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
