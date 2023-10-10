local config = require("leetcode.config")
local log = require("leetcode.logger")
local Description = require("leetcode.ui.description")
local api_question = require("leetcode.api.question")
local Console = require("leetcode.ui.console")
local utils = require("leetcode.utils")

---@class lc.Question
---@field file Path
---@field q lc.question_res
---@field description lc.Description
---@field bufnr integer
---@field console lc.Console
---@field lang string
local question = {}
question.__index = question

---@type table<integer, lc.Question>
_Lc_questions = {}
---@type integer
_Lc_curr_question = 0

---@private
function question:create_file()
    local snippets = self.q.code_snippets

    local snippet = {}

    for _, snip in pairs(snippets ~= vim.NIL and snippets or {}) do
        if snip.lang_slug == self.lang or snip.lang_slug == config.user.sql then
            snippet.code = snip.code
            snippet.lang = snip.lang_slug
            break
        end
    end

    if not snippet then return log.error("failed to fetch code snippet") end
    self.file:write(snippet.code, "w")
end

function question:mount()
    if not self.file:exists() then self:create_file() end

    vim.api.nvim_set_current_dir(self.file:parent().filename)
    vim.cmd("$tabe " .. self.file:absolute())
    _Lc_tabpage = vim.api.nvim_get_current_tabpage()

    self.bufnr = vim.api.nvim_get_current_buf()
    _Lc_curr_question = self.bufnr
    _Lc_questions[_Lc_curr_question] = self

    self.description = Description:init(self)
    self.console = Console:init(self)

    self:autocmds()
    return self
end

function question:autocmds()
    local group_id = vim.api.nvim_create_augroup("leetcode_questions", { clear = true })
    vim.api.nvim_create_autocmd("TabEnter", {
        group = group_id,
        callback = function()
            local questions = utils.curr_question_tabs()

            local tabpage = vim.api.nvim_get_current_tabpage()
            for _, q in ipairs(questions) do
                if q.tabpage == tabpage then _Lc_curr_question = q.question.bufnr end
            end
        end,
    })

    local q_group_id = vim.api.nvim_create_augroup("leetcode_question", {})
    vim.api.nvim_create_autocmd("BufWinEnter", {
        group = q_group_id,
        buffer = self.bufnr,
        callback = function() self.description.split:show() end,
    })

    vim.api.nvim_create_autocmd("BufWinLeave", {
        group = q_group_id,
        buffer = self.bufnr,
        callback = function() self.description.split:hide() end,
    })
end

---@param problem lc.Cache.Question
function question:init(problem)
    local tabp = utils.detect_duplicate_question(problem.title_slug, config.lang)
    if tabp then
        pcall(vim.cmd.tabnext, tabp)
        return log.info("Question already opened")
    end

    local q = api_question.by_title_slug(problem.title_slug)
    local lang = config.lang

    local ft = utils.filetype(lang)
    local fn = string.format("%s.%s.%s", q.frontend_id, q.title_slug, ft)
    local file = config.home:joinpath(fn)

    local obj = setmetatable({
        file = file,
        q = q,
        lang = lang,
    }, self)

    return obj:mount()
end

return question
