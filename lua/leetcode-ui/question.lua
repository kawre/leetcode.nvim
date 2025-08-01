local Description = require("leetcode-ui.split.description")
local Console = require("leetcode-ui.layout.console")
local Info = require("leetcode-ui.popup.info")
local Object = require("nui.object")

local api_question = require("leetcode.api.question")
local utils = require("leetcode.util")
local ui_utils = require("leetcode-ui.utils")
local config = require("leetcode.config")
local log = require("leetcode.logger")

---@alias lc.editor.section "imports" | "code"

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

---@param start_i integer
---@param end_i integer
---@param lines string[]|string
function Question:editor_set_lines(start_i, end_i, lines)
    if not (self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr)) then
        return
    end

    lines = type(lines) == "string" and vim.split(lines, "\n") or lines ---@cast lines string[]
    vim.api.nvim_buf_set_lines(self.bufnr, start_i, end_i, false, lines)
end

function Question:editor_reset()
    local new_lines = self:snippet() or ""
    self:editor_set_lines(0, -1, new_lines)
end

function Question:editor_reset_code()
    local new_lines = self:snippet(true) or ""
    self:editor_section_replace(new_lines, "code")
end

function Question:reset_previous_code()
    self:editor_reset_code()
    vim.schedule(function()
        log.info("Previous code found and reset. To undo, simply press `u` or use `:undo`.")
    end)
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
    ui_utils.win_set_winfixbuf(self.winid)

    self:open_buffer(existed)
end

---@param strict? boolean
function Question:editor_fold_imports(strict)
    if not (self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr)) then
        return
    end

    local range = self:editor_section_range("imports", true)
    if range.complete or range.end_i then
        vim.api.nvim_buf_call(self.bufnr, function()
            pcall(vim.cmd, ("%d,%dfold"):format(range.start_i or 1, range.end_i)) ---@diagnostic disable-line: param-type-mismatch
        end)
    elseif strict then
        range.log_not_found()
    end
end

function Question:editor_yank_code()
    if not (self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr)) then
        return
    end

    local range = self:editor_section_range("code")
    if range:is_valid_or_log() then
        vim.api.nvim_buf_call(self.bufnr, function()
            vim.cmd(("%d,%dyank"):format(range.start_i, range.end_i))
        end)
    end
end

---@param existed boolean
function Question:open_buffer(existed)
    ui_utils.buf_set_opts(self.bufnr, { buflisted = true })
    ui_utils.win_set_buf(self.winid, self.bufnr, true)

    vim.cmd([[match DiagnosticHint /@leet/]])

    if config.user.editor.fold_imports then
        self:editor_fold_imports(false)
    end

    if config.user.editor.reset_previous_code and (existed and self.cache.status == "ac") then
        self:reset_previous_code()
    end
end

---@return string[]?
function Question:inject_imports()
    local inject = config.user.injector[self.lang] or {}

    local imports = inject.imports
    local default_imports = config.imports[self.lang]

    local function valid_imports(tbl)
        if vim.tbl_isempty(tbl or {}) then
            return false
        end
        if not vim.islist(tbl) then
            log.error("Invalid imports format for language: " .. self.lang)
            return false
        end
        return true
    end

    if not imports then
        return default_imports
    end

    if type(imports) == "function" then
        local overriden = imports(vim.deepcopy(default_imports or {}))
        if not valid_imports(overriden) then
            return default_imports
        end
        return overriden
    end

    local resolved = type(imports) == "string" and { imports } or imports
    if not valid_imports(resolved) then
        return
    end

    local merged, seen = {}, {}
    local function add(list)
        for _, v in ipairs(list) do
            if not seen[v] then
                table.insert(merged, v)
                seen[v] = true
            end
        end
    end

    add(default_imports)
    add(resolved)

    return not vim.tbl_isempty(merged) and merged or nil
end

---@param before boolean
---@return string?
function Question:inject(before)
    local inject = config.user.injector[self.lang] or {}
    local inj = before and (inject.before or {}) or (inject.after or {})

    local res
    if type(inj) == "table" then
        res = table.concat(inj, "\n")
    elseif type(inj) == "string" then
        res = inj
    end

    if res and res ~= "" then
        return res
    else
        return nil
    end
end

---@param lines string|string[]
---@param name lc.editor.section
---@return string
function Question:editor_section(lines, name)
    local comment = utils.get_lang(self.lang).comment

    local start_tag = comment .. " " .. utils.section_tag(name, true)
    local end_tag = comment .. " " .. utils.section_tag(name, false)

    local str = type(lines) ~= "string" and table.concat(lines, "\n") or lines
    return table.concat({ start_tag, str, end_tag }, "\n")
end

---@param lines string[]|string
---@param name string
function Question:editor_section_replace(lines, name)
    local range = self:editor_section_range(name)

    if range:is_valid_or_log() then
        self:editor_set_lines(range.start_i - 1, range.end_i, lines)
    end
end

---@param code string
function Question:injector(code)
    local inject = config.user.injector[self.lang] or {}

    local parts = { self:editor_section(code, "code") }

    local before = self:inject(true)
    if before then
        table.insert(parts, 1, before)
    end

    local imports = self:inject_imports()
    if imports then
        table.insert(parts, 1, self:editor_section(table.concat(imports, "\n"), "imports"))
    end

    local after = self:inject(false)
    if after then
        table.insert(parts, after)
    end

    local gap = (inject.gap or 1) + 1
    return table.concat(parts, ("\n"):rep(gap))
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

        local picker = require("leetcode.picker")
        picker.language(self, function(slug)
            self.lang = slug
            self:handle_mount()
        end)
    end

    return self
end

---@class lc.Question.Editor.Range
---@field start_i? number
---@field end_i? number
---@field lines string[]
---@field sliced string[]
---@field complete boolean

---@param name string
---@param inclusive? boolean
function Question:editor_section_range(name, inclusive)
    local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
    local start_i, end_i

    local start_tag = utils.section_tag(name, true)
    local end_tag = utils.section_tag(name, false)

    for i, line in ipairs(lines) do
        if line:match(start_tag) then
            start_i = i + (inclusive and 0 or 1)
        elseif line:match(end_tag) then
            end_i = i - (inclusive and 0 or 1)
        end
    end

    local res = {
        start_i = start_i,
        end_i = end_i,
        lines = lines,
        complete = start_i and end_i,
    }

    res.log_not_found = function()
        if res.complete then
            return
        end

        local missing = {}
        if not res.start_i then
            table.insert(missing, ("`%s`"):format(start_tag))
        end
        if not res.end_i then
            table.insert(missing, ("`%s`"):format(end_tag))
        end

        log.warn(table.concat(missing, " and ") .. " not found.")
    end

    res.is_partial = function()
        return res.complete or (res.start_i or res.end_i)
    end

    res.is_valid_or_log = function()
        if res.complete then
            return true
        else
            res.log_not_found()
            return false
        end
    end

    return res
end

---@param submit boolean
---@return string
function Question:editor_submit_lines(submit)
    local range = self:editor_section_range("code")
    assert(range.complete, "Code section not found")

    local prefix = not submit and ("\n"):rep(range.start_i - 1) or ""
    return prefix .. table.concat(range.lines, "\n", range.start_i, range.end_i)
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
local LeetQuestion = Question ---@diagnostic disable-line: assign-type-mismatch

return LeetQuestion
