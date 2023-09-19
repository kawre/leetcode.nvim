local cache = require("leetcode.cache")
local log = require("leetcode.logger")
local config = require("leetcode.config")

local ui = require("leetcode.ui")
local dashboard = require("leetcode.ui.dashboard")
local gql = require("leetcode.graphql")

local path = require("plenary.path")

---@class lc.Commands
local M = {}

function M.lc_problems()
    local _, res = assert(pcall(cache.problems.read))

    ui.pick_one(
        res,
        "Select a Problem",
        cache.problems.formatter,

        ---@param problem lc.Problem
        function(problem)
            if not problem then return end

            local dir = config.user.directory .. "/solutions/"
            local fn = problem.index .. "." .. problem.title_slug .. ".java"
            local file = path:new(dir .. fn)

            if not file:exists() then
                local editor_data = gql.question.editor_data(problem.title_slug)

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
                    file:write(code, "w")
                end
            end

            vim.cmd("cd " .. dir)
            vim.cmd("e " .. file:absolute())

            ui.create_leetcode_win(problem)
        end
    )
end

function M.leetcode()
    M.authenticate()
    dashboard.setup()
    vim.cmd("Alpha | bd#")
end

function M.cookie_prompt()
    local cookie = require("leetcode.cache.cookie")

    ui.input(
        "Enter cookie",
        ---@param cookie_str string
        function(cookie_str)
            if not cookie_str then return end

            cookie.new(cookie_str)
            require("leetcode.ui.dashboard").update()
        end
    )
end

---Merge configurations into default configurations and set it as user configurations.
---
---@return lc.UserStatus | nil
function M.authenticate() gql.auth.user_status() end

return M
