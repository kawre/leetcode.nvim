---@module 'markup'

local config = require("leetcode.config")
local Description = require("leetcode.problem.description")
local Console = require("leetcode.problem.console")

---@class leet.problem
---@field cached leet.cache.problem
local M = Markup.object()

---@param problem leet.cache.problem
function M:new(problem)
    self.lang = config.lang
    self.cached = problem
end

function M:show()
    local tabp = Leet.util.detect_duplicate_question(self.cached.title_slug, config.lang)
    if tabp then
        return pcall(vim.api.nvim_set_current_tabpage, tabp)
    end

    local problem = Leet.api.problems.by_title_slug(self.cached.title_slug)
    if
        not problem --
        or (problem.is_paid_only and not config.auth.is_premium)
    then
        return Markup.log.warn("Question is for premium users only")
    end

    self.problem = problem

    vim.cmd.tabe()
    local path = self:path()
    vim.cmd("$tabe " .. path)

    self.desc = Description(self)
    self.console = Console(self)

    -- self.win = Markup.window({
    --     position = "current",
    --     hijack = true,
    --     -- fixed = true,
    --     -- file = path,
    --     minimal = false,
    -- })
    -- if self:snippet() then
    --     self:handle_mount()
    -- else
    --     local msg = ("Snippet for `%s` not found. Select a different language"):format(self.lang)
    --     Markup.log.warn(msg)
    --
    --     require("leetcode.pickers.language").pick_lang(self, function(snippet)
    --         self.lang = snippet.t.slug
    --         self:handle_mount()
    --     end)
    -- end
end

---@return string path, boolean existed
function M:path()
    local lang = Leet.util.get_lang(self.lang)
    local alt = lang.alt and ("." .. lang.alt) or ""

    local fn = ("%s.%s%s.%s"):format(
        self.problem.frontend_id,
        self.problem.title_slug,
        alt,
        lang.ft
    )
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

return M
