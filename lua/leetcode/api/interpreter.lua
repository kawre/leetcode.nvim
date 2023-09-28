local log = require("leetcode.logger")

local utils = require("leetcode.api.utils")
local config = require("leetcode.config")
local spinner = require("leetcode.logger.spinner")

---@class lc.Interpreter
local interpreter = {}

local check_state = {
    ["PENDING"] = "Pending…",
    ["STARTED"] = "Judging…",
    ["SUCCESS"] = "Finished",
    ["FAILURE"] = "Failed", -- CODE: 16
}

---@class lc.Interpret.body
---@field question question_response
---@field typed_code string
---@field data_input string

---@param title_slug string
---@param body lc.Interpret.body
---@param callback function
function interpreter.interpret_solution(title_slug, body, callback)
    utils.auth_guard()

    local url = string.format(config.domain .. "/problems/%s/interpret_solution/", title_slug)

    ---@type boolean, submission
    local ok, res = pcall(utils.post, url, body)
    assert(ok)

    local noti = spinner:init(check_state["PENDING"], "points")

    local function listener()
        interpreter.check(res.interpret_id, function(item)
            if item.status_code then
                noti:done(check_state[item.state])
                callback(item)
                return
            end

            noti:update(check_state[item.state])

            if item.state == "PENDING" then
                noti:change("points")
            elseif item.state == "STARTED" then
                noti:change("dot")
            end

            vim.defer_fn(listener, 500)
        end)
    end

    listener()
end

---@param id string
---@param cb function
---
---@return lc.Interpreter.Response
function interpreter.check(id, cb)
    local url = string.format(config.domain .. "/submissions/detail/%s/check/", id)
    utils._get(url, cb)

    -- ---@type boolean, lc.Interpreter.Response
    -- local ok, res = pcall(utils.get, url)
    -- assert(ok)
    --
    -- return res
end

return interpreter
