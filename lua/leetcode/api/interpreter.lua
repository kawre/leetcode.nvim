local log = require("leetcode.logger")
local urls = require("leetcode.api.urls")

local config = require("leetcode.config")

local t = require("leetcode.translator")

---@class leet.api.interpreter
local interpreter = {}

---@param item lc.interpreter_response
---
---@return lc.interpreter_response
local function resolve_item(item)
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
---@param cb function
---
---@return lc.Interpreter.Response
local function check(id, cb)
	local url = urls.check:format(id)
	Leet.api.get(url, { callback = cb })
end

-- local function fetch(url, opts)
--     Leet.api.post(url, {
--         body = opts.body,
--         callback = opts.callback,
--     })
-- end

---@param id string
---@param callback function
function interpreter.listener(id, callback)
	local function listen()
		check(id, function(item, err)
			if err then         -- error
				callback(nil, nil, err)
			elseif item.status_code then -- got results
				item = resolve_item(item)
				callback(item)
			else -- still judging
				local intervals = config.auth.is_premium and { 450, 450 } or { 450, 900 }
				local interval = item.sate == "STARTED" and intervals[2] or intervals[1]
				callback(nil, item.state)
				vim.defer_fn(listen, interval)
			end
		end)
	end

	listen()
end

---@class lc.Interpret.body
---@field question lc.question_res
---@field typed_code string
---@field data_input string

---@param submit boolean
---@param problem leet.problem
---@param body lc.Interpret.body|string
---@param callback function
function interpreter.run(submit, problem, body, callback)
	local url = (submit and urls.submit or urls.interpret):format(problem.problem.title_slug)

	Leet.api.post(url, {
		body = body,
		callback = function(res, err)
			if err then
				if err.status == 429 then
					err.msg = "You have attempted to run code too soon"
					err.lvl = vim.log.levels.WARN
				end
				callback(nil, nil, err)
			else
				local id = submit and res.submission_id or res.interpret_id
				problem.console.testcase:snapshot(id, res)
				problem.console.result:clear()
				interpreter.listener(id, callback)
			end
		end,
	})
end

return interpreter
