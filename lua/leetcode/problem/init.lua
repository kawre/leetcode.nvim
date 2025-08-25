---@module 'markup'

local config = require("leetcode.config")
local Description = require("leetcode.problem.description")
local Console = require("leetcode.problem.console")

---@class leet.problem
---@field cached leet.cache.problem
---@field console leet.problem.console
---@field description leet.problem.description
---@overload fun(problem: leet.cache.problem): leet.problem
local M = Markup.object()

---@param cached leet.cache.problem
---@param problem leet.cache.problem
function M:new(cached, problem)
    self.lang = config.lang
    self.cached = cached
    self.problem = problem

    table.insert(Leet.active_problems, self)
    self:open_buf()

    self.description = Description(self)
    self.console = Console(self)
end

function M:tabpage()
    return vim.api.nvim_win_get_tabpage(self.win)
end

function M:valid()
    if not self.buf or not vim.api.nvim_buf_is_valid(self.buf) then
        return false
    end
    if not self.win or not vim.api.nvim_win_is_valid(self.win) then
        return false
    end
    return true
end

function M:open_buf()
    if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
        return
    end

    local path, existed = self:path()
    vim.cmd("$tabe " .. path)
    self.buf = vim.api.nvim_get_current_buf()
    self.win = vim.api.nvim_get_current_win()
    vim.wo[self.win].winfixbuf = true

    vim.bo[self.buf].buflisted = true
    vim.api.nvim_win_set_buf(self.win, self.buf)

    if config.user.editor.fold_imports then
        self:editor_fold_imports(false)
    end

    if config.user.editor.reset_previous_code and (existed and self.cached.status == "ac") then
        self:reset_previous_code()
    end
end

function M:filename(ft)
    local lang = Leet.util.get_lang(self.lang)
    local alt = lang.alt and ("." .. lang.alt) or ""

    return ("%s.%s%s.%s"):format(
        self.problem.frontend_id,
        self.problem.title_slug,
        alt,
        ft or lang.ft
    )
end

---@return string path, boolean existed
function M:path()
    local fn = self:filename()
    self.file = config.storage.home:joinpath(fn)
    local existed = self.file:exists()

    if not existed then
        self.file:write(self:snippet(), "w")
    end

    return self.file:absolute(), existed
end

---@param raw? boolean
function M:snippet(raw)
    local snippets = self.problem.code_snippets ~= vim.NIL and self.problem.code_snippets or {}
    local snip = vim.tbl_filter(function(snip)
        return snip.lang_slug == self.lang
    end, snippets)[1]
    if not snip then
        return
    end

    local code = snip.code:gsub("\r\n", "\n")
    return raw and code or self:injector(code)
end

---@param code string
function M:injector(code)
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

---@param before boolean
---@return string?
function M:inject(before)
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

---@return string[]?
function M:inject_imports()
    local inject = config.user.injector[self.lang] or {}

    local imports = inject.imports
    local default_imports = config.imports[self.lang]

    local function valid_imports(tbl)
        if vim.tbl_isempty(tbl or {}) then
            return false
        end
        if not vim.islist(tbl) then
            Markup.log.error("Invalid imports format for language: " .. self.lang)
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

---@param lines string|string[]
---@param name lc.editor.section
---@return string
function M:editor_section(lines, name)
    local comment = Leet.util.get_lang(self.lang).comment

    local start_tag = comment .. " " .. Leet.util.section_tag(name, true)
    local end_tag = comment .. " " .. Leet.util.section_tag(name, false)

    local str = type(lines) ~= "string" and table.concat(lines, "\n") or lines
    return table.concat({ start_tag, str, end_tag }, "\n")
end

---@param name string
---@param inclusive? boolean
function M:editor_section_range(name, inclusive)
    local lines = vim.api.nvim_buf_get_lines(self.buf, 0, -1, false)
    local start_i, end_i

    local start_tag = Leet.util.section_tag(name, true)
    local end_tag = Leet.util.section_tag(name, false)

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

        Markup.log.warn(table.concat(missing, " and ") .. " not found.")
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

function M:editor_yank_code()
    if not (self.buf and vim.api.nvim_buf_is_valid(self.buf)) then
        return
    end

    local range = self:editor_section_range("code")
    if range:is_valid_or_log() then
        vim.api.nvim_buf_call(self.buf, function()
            vim.cmd(("%d,%dyank"):format(range.start_i, range.end_i))
        end)
    end
end

---@param strict? boolean
function M:editor_fold_imports(strict)
    if not (self.buf and vim.api.nvim_buf_is_valid(self.buf)) then
        return
    end

    local range = self:editor_section_range("imports", true)
    if range.complete or range.end_i then
        vim.api.nvim_buf_call(self.buf, function()
            pcall(vim.cmd, ("%d,%dfold"):format(range.start_i or 1, range.end_i)) ---@diagnostic disable-line: param-type-mismatch
        end)
    elseif strict then
        range.log_not_found()
    end
end

---@param start_i integer
---@param end_i integer
---@param lines string[]|string
function M:editor_set_lines(start_i, end_i, lines)
    if not (self.buf and vim.api.nvim_buf_is_valid(self.buf)) then
        return
    end

    lines = type(lines) == "string" and vim.split(lines, "\n") or lines ---@cast lines string[]
    vim.api.nvim_buf_set_lines(self.buf, start_i, end_i, false, lines)
end

---@param lines string[]|string
---@param name string
function M:editor_section_replace(lines, name)
    local range = self:editor_section_range(name)

    if range:is_valid_or_log() then
        self:editor_set_lines(range.start_i - 1, range.end_i, lines)
    end
end

function M:editor_reset_code()
    local new_lines = self:snippet(true) or ""
    self:editor_section_replace(new_lines, "code")
end

---@param submit boolean
---@return string
function M:editor_submit_lines(submit)
    local range = self:editor_section_range("code")
    assert(range.complete, "Code section not found")

    local prefix = not submit and ("\n"):rep(range.start_i - 1) or ""
    return prefix .. table.concat(range.lines, "\n", range.start_i, range.end_i)
end

function M:reset_previous_code()
    self:editor_reset_code()
    vim.schedule(function()
        Markup.log("Previous code found and reset. To undo, simply press `u` or use `:undo`.")
    end)
end

return M
