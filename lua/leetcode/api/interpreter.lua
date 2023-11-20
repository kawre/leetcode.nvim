local log = require("leetcode.logger")
local t = require("leetcode.translator")
local urls = require("leetcode.api.urls")

local utils = require("leetcode.api.utils")
local config = require("leetcode.config")
local spinner = require("leetcode.logger.spinner")

---@class lc.Interpreter
local interpreter = {}

local check_state = {
    ["PENDING"] = t("Pending") .. "…",
    ["STARTED"] = t("Judging") .. "…",
    ["SUCCESS"] = t("Finished"),
    ["FAILURE"] = t("Failed"), -- CODE: 16
}

---@param item lc.interpreter_response
---
---@return lc.interpreter_response
function interpreter:handle_item(item)
    local success = false
    if item.status_code == 10 then
        success = item.compare_result:match("^[1]+$") and true or false
        item.status_msg = success and "Accepted" or "Wrong Answer"
    end

    local submission = false
    if item.submission_id then
        submission = not item.submission_id:find("runcode") and true or false
    end
    local hl = success and "leetcode_ok" or "leetcode_error"

    if item.status_code == 15 and item.invalid_testcase then
        item.status_msg = "Invalid Testcase"
    end

    item._ = {
        title = " " .. t(item.status_msg),
        hl = hl,
        success = success,
        submission = submission,
    }

    return item
end

---@param id string
---@param callback function
function interpreter.listener(id, callback)
    local noti = spinner:init(check_state["PENDING"], "points")

    local function listen()
        interpreter.check(id, function(item, err)
            if err then
                noti:stop(err.msg, false, { timeout = 1000 })
                return
            end

            if item.status_code then
                item = interpreter:handle_item(item)
                noti:stop(item.status_msg, item._.success)
                return callback(item)
            else
                noti:update(check_state[item.state])
                if item.state == "PENDING" then
                    noti:change("points")
                elseif item.state == "STARTED" then
                    noti:change("dot")
                end
                vim.defer_fn(listen, 500)
            end
        end)
    end

    listen()
end

---@class lc.Interpret.body
---@field question lc.question_res
---@field typed_code string
---@field data_input string

---@param title_slug string
---@param body lc.Interpret.body
---@param callback function
function interpreter.interpret_solution(title_slug, body, callback)
    local url = urls.interpret:format(title_slug)
    local res, err = interpreter.fetch(url, body)
    if err then return log.error(err.msg) end

    interpreter.listener(res.interpret_id, callback)
end

function interpreter.submit(title_slug, body, callback)
    local url = urls.submit:format(title_slug)
    local res, err = interpreter.fetch(url, body)
    if err then return log.error(err.msg) end

    interpreter.listener(res.submission_id, callback)
end

---@param id string
---@param cb function
---
---@return lc.Interpreter.Response
function interpreter.check(id, cb)
    local url = urls.check:format(id)
    utils.get(url, cb)
end

function interpreter.fetch(url, body)
    local res, err = utils.post(url, body)
    if err then return nil, err end
    return res
end

return interpreter
