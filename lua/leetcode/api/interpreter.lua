local log = require("leetcode.logger")
local urls = require("leetcode.api.urls")

local utils = require("leetcode.api.utils")
local spinner = require("leetcode.logger.spinner")

local t = require("leetcode.translator")

---@class lc.Interpreter
local interpreter = {}

local check_state = {
    ["PENDING"] = "Pending…",
    ["STARTED"] = "Judging…",
    ["SUCCESS"] = "Finished",
    ["FAILURE"] = "Failed", -- CODE: 16
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
                require("leetcode.runner"):stop()
                return noti:stop(err.msg, false)
            end

            if item.status_code then
                item = interpreter:handle_item(item)
                noti:stop(item.status_msg, item._.success)
                return callback(item)
            end

            local interval = 500
            noti:update(check_state[item.state])
            if item.state == "PENDING" then
                noti:change("points")
            elseif item.state == "STARTED" then
                noti:change("dot")
                interval = 1000
            end

            vim.defer_fn(listen, interval)
        end)
    end

    listen()
end

---@class lc.Interpret.body
---@field question lc.question_res
---@field typed_code string
---@field data_input string

---@param title_slug string
---@param body lc.Interpret.body|string
---@param callback function
function interpreter.interpret_solution(title_slug, body, callback)
    local url = urls.interpret:format(title_slug)

    interpreter.fetch(url, {
        body = body,
        callback = function(res, success)
            callback(success)
            if success then interpreter.listener(res.interpret_id, callback) end
        end,
    })
end

---@param title_slug string
---@param body lc.Interpret.body|string
---@param callback function
function interpreter.submit(title_slug, body, callback)
    local url = urls.submit:format(title_slug)

    interpreter.fetch(url, {
        body = body,
        callback = function(res, success)
            callback(success)
            if success then interpreter.listener(res.submission_id, callback) end
        end,
    })
end

---@param id string
---@param cb function
---
---@return lc.Interpreter.Response
function interpreter.check(id, cb)
    local url = urls.check:format(id)
    utils.get(url, { callback = cb })
end

function interpreter.fetch(url, opts)
    utils.post(url, {
        body = opts.body,
        callback = function(res, err)
            if err then
                if err.status == 429 then
                    err.msg = "You have attempted to run code too soon"
                    err.lvl = vim.log.levels.WARN
                end
                opts.callback(log.err(err), false)
            else
                opts.callback(res, true)
            end
        end,
    })
end

return interpreter
