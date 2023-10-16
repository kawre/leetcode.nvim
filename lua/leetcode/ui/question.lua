local config = require("leetcode.config")
local log = require("leetcode.logger")
local Description = require("leetcode.ui.description")
local api_question = require("leetcode.api.question")
local Console = require("leetcode.ui.console")
local utils = require("leetcode.utils")
local async = require("plenary.async")
local Hints = require("leetcode.ui.hints")

---@class lc.Question
---@field file Path
---@field q lc.question_res
---@field description lc.Description
---@field bufnr integer
---@field console lc.Console
---@field lang string
---@field sql string
---@field cache lc.Cache.Question
local Question = {}
Question.__index = Question

---@param q lc.QuestionResponse
---
---@return boolean
local function is_sql(q)
    for _, value in ipairs(q.topic_tags or {}) do
        if value.slug == "database" then return true end
    end

    return false
end

function Question:get_snippet()
    local snippets = self.q.code_snippets ~= vim.NIL and self.q.code_snippets or {}
    return vim.tbl_filter(function(snip) return snip.lang_slug == self.lang end, snippets)[1] or {}
end

---@private
function Question:create_file()
    local lang = utils.get_lang(is_sql(self.q) and config.sql or config.lang)
    local suffix = lang.sql and "-" .. lang.short or ""
    local fn = string.format("%s.%s%s.%s", self.q.frontend_id, self.q.title_slug, suffix, lang.ft)

    self.file = config.home:joinpath(fn)
end

function Question:mount()
    self:create_file()
    if not self.file:exists() then self.file:write(self:get_snippet().code, "w") end

    vim.api.nvim_set_current_dir(config.home:absolute())
    vim.cmd("$tabe " .. self.file:absolute())

    self.bufnr = vim.api.nvim_get_current_buf()
    self.winid = vim.api.nvim_get_current_win()
    table.insert(_Lc_questions, self)

    self.description = Description:init(self)
    self.console = Console:init(self)
    self.hints = Hints:init(self)

    self:autocmds()
    return self
end

function Question:autocmds()
    -- local group_id = vim.api.nvim_create_augroup("leetcode_questions", { clear = true })

    -- local q_group_id = vim.api.nvim_create_augroup("leetcode_question", {})
    -- vim.api.nvim_create_autocmd("BufWinEnter", {
    --     group = q_group_id,
    --     buffer = self.bufnr,
    --     callback = function()
    --         log.info("wtf")
    --         self.description.split:show()
    --     end,
    -- })
    --
    -- vim.api.nvim_create_autocmd("BufWinLeave", {
    --     group = q_group_id,
    --     buffer = self.bufnr,
    --     callback = function() self.description.split:hide() end,
    -- })
end

function Question:handle_mount()
    if self:get_snippet() then
        self:mount()
    else
        local msg =
            string.format("Snippet for `%s` not found. Select a different language", self.lang)
        log.warn(msg)

        require("leetcode.pickers.language").pick_lang(self, function(snippet)
            self.lang = snippet.t.slug
            self:mount()
        end)
    end
end

---@param problem lc.Cache.Question
function Question:init(problem)
    local tabp = utils.detect_duplicate_question(problem.title_slug)
    if tabp then return pcall(vim.cmd.tabnext, tabp) end

    local q = api_question.by_title_slug(problem.title_slug)
    if q.is_paid_only and not config.auth.is_premium then
        return log.warn("Question is for premium users only")
    end

    local lang = utils.get_lang(is_sql(q) and config.sql or config.lang)

    local obj = setmetatable({
        q = q,
        lang = lang.slug,
        cache = problem,
    }, self)

    return obj:handle_mount()
end

return Question
