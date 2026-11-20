--- The text of the UI in English, which every other language follows.
---@class leet.i18n.text
local M = {}

local MONTHS =
	{ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

local function plural(count, one, many)
	return (count == 1 and one or many):format(count)
end

-- Pages and the launcher
M.welcome = "Welcome"
M.account = "Account"
M.menu = "Menu"
M.problems = "Problems"
M.statistics = "Statistics"
M.loading = "Loading"
M.signing_in = "Signing in"
M.continue = "Continue"
M.daily_challenge = "Daily challenge"
M.quit = "Quit"
M.quit_desc = "close leetcode.nvim"
M.back = "Back"
M.back_desc = "return to the menu"
M.problems_desc = "browse, random, recent"
M.statistics_desc = "progress and skills"
M.account_desc = "cookie, sign out"
M.sign_in = "Sign in"
M.sign_in_desc = "paste your session cookie"
M.cookie = "Cookie"
M.cookie_desc = "paste a new session cookie"
M.sign_out = "Sign out"
M.sign_out_desc = "forget this session"

---@param part "morning"|"afternoon"|"evening"|"night"
---@param name string
function M.greeting(part, name)
	return ("Good %s, %s"):format(part, name)
end

---@param rate number
function M.accepted_rate(rate)
	return ("%.1f%% accepted"):format(rate)
end

--- Today, as `os.date` takes it.
M.date_format = "%b %-d"

M.just_now = "just now"

---@param count integer
---@param unit "w"|"d"|"h"|"m"
function M.ago(count, unit)
	return ("%d%s ago"):format(count, unit)
end

-- The problems page
M.browse = "Browse"
M.browse_desc = "Search and filter every problem"
M.random = "Random"
M.random_desc = "Pick one for me"
M.refresh = "Refresh"
M.refresh_desc = "Fetch the list again"
M.todays_problem = "Today's problem"
M.recent = "Recent"
M.open = "Open"
M.recent_empty = "Problems you work on will show up here"

-- Statistics
M.update = "Update"
M.updating = "Updating"
M.updated = "Updated"
M.nothing_yet = "Nothing yet"
M.languages = "Languages"
M.solved_count = "solved"
M.submissions = "submissions"
M.active_days = "active days"
M.best_streak = "best streak"

---@param skill "fundamental"|"intermediate"|"advanced"
function M.skill(skill)
	return (skill:gsub("^%l", string.upper))
end

---@param month integer 1 to 12
function M.month(month)
	return MONTHS[month]
end

-- Problems and their state
---@param difficulty string as LeetCode names it, or "All"
function M.difficulty(difficulty)
	return difficulty
end

---@param status "ac"|"notac"|"todo"
function M.status(status)
	return ({ ac = "Solved", notac = "Attempted", todo = "Not solved" })[status] or "Not solved"
end

-- The browser
M.search_problems = "Search problems"
M.to_search = "to search"
M.no_matches = "No problems match these filters"
M.any = "Any"
M.todo = "Todo"
M.free = "Free"

--- After the number shown, as "12 of 3000".
---@param total integer
function M.of_total(total)
	return (" of %d"):format(total)
end

-- The description
M.premium = "Premium"
M.hints = "Hints"
M.topics = "Topics"
M.similar_questions = "Similar Questions"
M.no_hints = "No hints available"

---@param rate string
---@param total string
function M.acceptance(rate, total)
	return ("%s of %s"):format(rate, total)
end

-- The console
M.tab_testcase = "Testcase"
M.tab_result = "Result"
M.add = "add"
M.remove = "remove"
M.reset = "reset"
M.edit = "edit"
M.switch = "switch"
M.results_empty = "Run your code to see how it does."
--- Two keys go in, `:Leet run` and `:Leet submit`.
M.results_how = "%s tries the testcases, %s sends it to be judged"

---@param index integer
function M.case(index)
	return ("Case %d"):format(index)
end

-- The judge at work
M.step_queued = "Queued"
M.step_judging = "Judging"
M.step_result = "Result"
M.judging_submit = "Submitting your solution"
M.judging_run = "Running your testcases"

-- Results
M.runtime = "Runtime"
M.memory = "Memory"
M.beats = "beats"
M.input = "Input"
M.output = "Output"
M.expected = "Expected"
M.use_testcase = "Use testcase"
M.last_input = "Last input"
M.stdout = "Stdout"
M.fullscreen = "Fullscreen"
M.show_all = "Show all"
M.close = "close"
M.judge_failed = "The judge failed, not your code. Try running it again."
M.too_soon = "Too soon"
M.run_failed = "Run failed"
M.runner_busy = "Runner is busy"
M.something_went_wrong = "Something went wrong"
--- The key to run again goes in.
M.too_soon_hint = "LeetCode takes a run every few seconds. Wait a moment, then %s again."

---@param correct integer
---@param total integer
function M.passed(correct, total)
	return ("%d/%d passed"):format(correct, total)
end

---@param count integer
function M.lines(count)
	return plural(count, "%d line", "%d lines")
end

---@param count integer
function M.more_lines(count)
	return plural(count, "… %d more line", "… %d more lines")
end

---@param index integer
function M.invalid_case(index)
	return ("Case %d is not a valid input for this problem."):format(index)
end

---@param index integer
function M.edit_case(index)
	return ("Edit Case %d"):format(index)
end

--- While a question is fetched, from somewhere with no loader of its own.
---@param title string
function M.opening(title)
	return ("Opening %s"):format(title)
end
M.opening_daily = "Opening the daily challenge"
M.drawing_random = "Picking a random problem"

return M
