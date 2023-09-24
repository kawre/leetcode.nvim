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
---@field bufnr bufnr
---@field console lc.Console
local question = {}
question.__index = question

---@type table<bufnr, lc.Question>
problems = {}

---@type bufnr
curr_question = 0

---@private
function question:create_file()
    local snippets = self.q.code_snippets

    local code
    for _, snippet in pairs(snippets or {}) do
        if snippet.lang_slug == config.user.lang or snippet.lang_slug == config.user.sql then
            code = snippet.code
            break
        end
    end

    if not code then
        log.error("failed to fetch code snippet")
    else
        self.file:write(code, "w")
    end
end

function question:mount()
    if not self.file:exists() then self:create_file() end

    vim.api.nvim_set_current_dir(self.file:parent().filename)
    vim.cmd.tabe(self.file:absolute())

    self.bufnr = vim.api.nvim_get_current_buf()
    curr_question = self.bufnr
    problems[self.bufnr] = self

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
