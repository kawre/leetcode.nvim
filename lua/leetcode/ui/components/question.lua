local Split = require("nui.split")
local path = require("plenary.path")
local config = require("leetcode.config")
local log = require("leetcode.logger")
local Description = require("leetcode.ui.components.description")
local gql = require("leetcode.api.graphql")
local Console = require("leetcode.ui.components.console")
local Runner = require("leetcode.runner")

---@class lc.Question
---@field file Path
---@field q question_response
---@field description lc.Description
---@field bufnr integer
---@field console lc.Console
local question = {}
question.__index = question

---@type table<integer, lc.Question>
Questions = {}

---@type integer
Curr_question = 0

---@private
function question:create_file()
    local snippets = self.q.code_snippets

    local snippet = {}

    for _, snip in pairs(snippets ~= vim.NIL and snippets or {}) do
        if snip.lang_slug == config.user.lang or snip.lang_slug == config.user.sql then
            snippet.code = snip.code
            snippet.lang = snip.lang_slug
            break
        end
    end

    if not snippet then return log.error("failed to fetch code snippet") end

    local q = self.q
    local dir = config.user.directory .. "/solutions/"
    local fn = string.format("%s.%s.%s", q.frontend_id, q.title_slug, snippet.lang)
    local file = path:new(dir .. fn)

    file:write(snippet.code, "w")
    self.file = file
end

function question:mount()
    if not self.file:exists() then self:create_file() end

    vim.api.nvim_set_current_dir(self.file:parent().filename)
    vim.cmd.tabe(self.file:absolute())

    self.bufnr = vim.api.nvim_get_current_buf()
    Curr_question = self.bufnr
    Questions[Curr_question] = self

    self.description = Description:init(self)
    self.console = Console:init(self)

    return self
end

---@param problem lc.Problem
function question:init(problem)
    local q = gql.question.by_title_slug(problem.title_slug)

    local dir = config.user.directory .. "/solutions/"
    local fn = string.format("%s.%s.%s", q.frontend_id, q.title_slug, config.lang)
    local file = path:new(dir .. fn)

    local obj = setmetatable({
        file = file,
        q = q,
    }, self)

    return obj:mount()
end

return question
