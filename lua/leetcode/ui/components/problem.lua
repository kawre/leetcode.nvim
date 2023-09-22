local Split = require("nui.split")
local path = require("plenary.path")
local config = require("leetcode.config")
local log = require("leetcode.logger")
local description = require("leetcode.ui.components.description")
local gql = require("leetcode.graphql")

---@class lc.Problem.second
---@field split NuiSplit
---@field file Path
---@field problem any
---@field description lc.Description
local problem = {}
problem.__index = problem

problems = {}

---@private
function problem:create_file()
    local editor_data = gql.question.editor_data(self.problem.title_slug)

    local code
    if editor_data.code_snippets ~= vim.NIL then
        for _, v in ipairs(editor_data.code_snippets) do
            if v.langSlug == config.user.lang or v.langSlug == config.user.sql then
                code = v.code
                break
            end
        end
    end

    if not code then
        log.error("failed to fetch code snippet")
    else
        self.file:write(code, "w")
    end
end

function problem:mount()
    if not self.file:exists() then self:create_file() end

    vim.api.nvim_set_current_dir(self.file:parent().filename)
    vim.cmd("edit " .. self.file:absolute())

    self.description = description:init(self)
    self.description:mount()
end

---@param problem lc.Problem
function problem:init(problem)
    local dir = config.user.directory .. "/solutions/"
    local fn = problem.index .. "." .. problem.title_slug .. "." .. config.user.lang
    local file = path:new(dir .. fn)

    local obj = setmetatable({
        file = file,
        problem = problem,
    }, self)

    return obj
end

return problem
