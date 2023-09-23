local path = require("plenary.path")
local async = require("plenary.async")

local config = require("leetcode.config")
local gql = require("leetcode.api.graphql")

local file = path:new(config.user.directory .. "/.problems")

---@class lc.Problem
---@field index string
---@field title string
---@field title_slug string
---@field ac_rate number
---@field difficulty "Easy" | "Medium" | "Hard"

local M = {}

local function populate()
    file:touch()
    local problems = assert(gql.problems.all())
    file:write(vim.json.encode(problems), "w")
end

---@return lc.Problem[] | nil
function M.read()
    M.update()

    local contents = file:read()

    local ok, problems = pcall(M.parse, contents)
    if not ok then return end

    return problems
end

function M.update()
    local stats = file:_stat()

    if vim.tbl_isempty(stats) then
        assert(populate())
        return
    end

    local mod_time = stats.mtime.sec
    local curr_time = os.time()

    if (curr_time - mod_time) > 60 * 60 * 24 * 7 then
        -- logger.info("Updating cache. This way take a while...")
        assert(populate())
    end
end

function M.get_by_title_slug(title_slug)
    local problems = M.read()

    for _, p in ipairs(problems or {}) do
        if p.title_slug == title_slug then return p end
    end

    return nil
end

---@param problem lc.Problem
---
---@return string
M.formatter = function(problem)
    return string.format(
        "%d. %s (%d%%, %s)",
        problem.index,
        problem.title,
        problem.ac_rate,
        problem.difficulty
    )
end

---@param problems_str string
---
---@return lc.Problem[]
function M.parse(problems_str)
    ---@type boolean, lc.Problem[]
    local ok, problems = pcall(vim.json.decode, problems_str)
    assert(ok)

    return problems
end

return M
