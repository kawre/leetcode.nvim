---@module 'mini.test'

local helpers = dofile("tests/helpers.lua")
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_case = function()
			helpers.boot(child)
		end,
		post_once = function()
			child.stop()
		end,
	},
})

local function open(cookie)
	child.lua(([[
		_G.cookie = %s
		menu = require("leetcode.ui.menu")
		menu.win.buf = vim.api.nvim_get_current_buf()
		menu.win:show()
		menu.render()
		vim.wait(100, function() reactive.flush(); return menu.page() ~= "loading" end, 5)
		reactive.flush()
	]]):format(cookie and "{ csrftoken = 'x' }" or "nil"))
end

local function contains(text)
	return child.lua_get(("contains(menu.win.buf, %q)"):format(text))
end

T["signed out shows the sign in page"] = function()
	open(false)
	eq(child.lua_get("menu.page()"), "signin")
	eq(contains("Sign in"), true)
	eq(contains("paste your session cookie"), true)
end

T["signed in shows the main page"] = function()
	open(true)
	eq(child.lua_get("menu.page()"), "menu")
	eq(contains("Problems"), true)
	eq(contains("Statistics"), true)
	eq(contains("Quit"), true)
end

T["the greeting follows the signed in user"] = function()
	open(true)
	eq(contains("tester"), true)
	eq(contains("42"), true)
end

T["today shows the daily challenge"] = function()
	open(true)
	eq(contains("Daily challenge"), true)
	eq(contains("15. 3Sum"), true)
	eq(contains("Not solved · Medium"), true)
end

T["today has the date and how many pass"] = function()
	child.lua([[
		local problems = package.loaded["leetcode.cache.problems"]
		local by_slug = problems.by_slug
		problems.by_slug = function(slug)
			local problem = by_slug(slug)
			problem.status, problem.ac_rate = "ac", 41.24
			return problem
		end
	]])
	open(true)
	-- The daily challenge arrives a moment after the menu: wait for it from
	-- here, so the child's loop turns between the questions.
	local today = child.lua_get("os.date('%b %-d')")
	eq(
		vim.wait(2000, function()
			child.lua("reactive.flush()")
			return contains(today)
		end, 10),
		true
	)
	eq(contains("Solved · Medium · 41.2% accepted"), true)
end

T["today opens with t"] = function()
	open(true)
	child.lua([[
		daily = false
		require("leetcode.cmd").qot = function() daily = true end
	]])
	child.type_keys("t")
	eq(child.lua_get("daily"), true)
end

T["the launcher keeps its shape when narrow"] = function()
	open(true)
	child.lua([[
		vim.cmd("vnew")
		vim.api.nvim_win_set_width(menu.win.win, 60)
		menu.view:request_commit()
		reactive.flush()
		reactive.flush()
	]])
	eq(contains("progress and skills"), true)
	eq(contains("Problems"), true)
	eq(contains("solved"), true)
end

T["the header swaps to the calendar"] = function()
	open(true)
	eq(contains("leetcode.nvim"), true)
end

T["keys change the page and clean up"] = function()
	open(true)
	child.type_keys("p")
	child.lua("reactive.flush()")
	eq(child.lua_get("menu.page()"), "menu.problems")
	eq(contains("Random"), true)
	eq(contains("Statistics"), false)

	child.type_keys("q")
	child.lua("reactive.flush()")
	eq(child.lua_get("menu.page()"), "menu")
	eq(contains("Statistics"), true)
end

T["enter presses the button under the cursor"] = function()
	open(true)
	child.lua([[
		local rows = buffer_text(menu.win.buf)
		for i, line in ipairs(rows) do
			if line:find("Statistics", 1, true) then
				local col = #line:match("^%s*")
				vim.api.nvim_win_set_cursor(0, { i, col })
			end
		end
	]])
	child.type_keys("<CR>")
	child.lua("reactive.flush()")
	eq(child.lua_get("menu.page()"), "menu.statistics")
end

T["coming back skips the intro and keeps the data"] = function()
	open(true)
	child.lua([[
		Markup.animate.enabled = true
		Markup.animate.manual = true
		fetches = streak_fetches
	]])
	child.type_keys("p")
	child.lua("reactive.flush(); Markup.animate.tick(3000); reactive.flush(); reactive.flush()")
	child.type_keys("q")
	child.lua("reactive.flush(); Markup.animate.tick(3000); reactive.flush(); reactive.flush()")
	eq(contains("solved"), true)
	eq(child.lua_get("streak_fetches"), child.lua_get("fetches"))

	-- The row under the cursor may still fade in, but the intro takes far longer.
	child.lua("Markup.animate.tick(200)")
	eq(child.lua_get("Markup.animate.running()"), false)
end

T["a new page still makes an entrance"] = function()
	open(true)
	child.lua([[
		Markup.animate.enabled = true
		Markup.animate.manual = true
	]])
	child.type_keys("p")
	child.lua("reactive.flush()")
	eq(child.lua_get("Markup.animate.running()"), true)
end

T["the cursor only stops on buttons"] = function()
	open(true)
	child.lua([[
		local rows = buffer_text(menu.win.buf)
		for i, line in ipairs(rows) do
			if line:find("Problems", 1, true) then
				button_row = i
				vim.api.nvim_win_set_cursor(0, { i, (line:find("Problems", 1, true)) })
			end
		end
		menu.view.cursor = nil
		menu.view:snap_cursor()
	]])
	child.type_keys("j")
	eq(child.lua_get("vim.api.nvim_get_current_line():find('Statistics', 1, true) ~= nil"), true)
end

T["the selected row stands in for the cursor"] = function()
	open(true)
	eq(child.lua_get("vim.o.guicursor:find('MarkupHiddenCursor', 1, true) ~= nil"), true)

	child.cmd("tabnew")
	eq(child.lua_get("vim.o.guicursor:find('MarkupHiddenCursor', 1, true)"), vim.NIL)
end

T["one press moves between rows in both directions"] = function()
	open(true)
	child.lua([[
		for i, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("Problems", 1, true) then
				vim.api.nvim_win_set_cursor(0, { i, (line:find("Problems", 1, true)) })
			end
		end
		menu.view.cursor = nil
		menu.view:snap_cursor()
	]])

	local function on(text)
		return child.lua_get(
			("vim.api.nvim_get_current_line():find(%q, 1, true) ~= nil"):format(text)
		)
	end

	child.type_keys("j")
	eq(on("Statistics"), true)
	child.type_keys("j")
	eq(on("Account"), true)
	child.type_keys("k")
	eq(on("Statistics"), true)
	child.type_keys("k")
	eq(on("Problems"), true)
end

T["rows have a line between them"] = function()
	open(true)
	child.lua([[
		for i, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("Problems", 1, true) and not first then first = i end
			if line:find("Statistics", 1, true) and not second then second = i end
		end
	]])
	eq(child.lua_get("second - first"), 2)
end

T["the breadcrumb shows only away from the menu"] = function()
	open(true)
	eq(contains("Menu"), false)
	child.lua([[menu.set_page("menu.cookie"); reactive.flush()]])
	eq(contains("Menu"), true)
end

T["a short window can still show the whole dashboard"] = function()
	child.o.lines = 14
	-- What many configs set, which used to undo every scroll.
	child.o.scrolloff = 8
	open(true)
	child.lua([[
		visible = function(text)
			local first, last = vim.fn.line("w0"), vim.fn.line("w$")
			for i = first, last do
				if (vim.fn.getline(i)):find(text, 1, true) then return true end
			end
			return false
		end
	]])
	eq(child.lua_get("visible('hard')"), false)

	for _ = 1, 40 do
		child.type_keys("j")
	end
	eq(child.lua_get("visible('hard')"), true)

	for _ = 1, 60 do
		child.type_keys("k")
	end
	-- Back at the top, where the greeting is.
	eq(child.lua_get("vim.fn.line('w0')"), 1)
	eq(child.lua_get("visible('leetcode.nvim')"), true)
end

T["navigation explains itself"] = function()
	open(true)
	eq(contains("browse, random, recent"), true)
	eq(contains("progress and skills"), true)
end

T["navigation comes before the numbers"] = function()
	open(true)
	child.lua([[
		for i, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("Problems", 1, true) and not nav then nav = i end
			if line:find("hard", 1, true) and not summary then summary = i end
		end
	]])
	eq(child.lua_get("nav < summary"), true)
end

T["the row under the cursor is marked"] = function()
	open(true)
	child.lua([[
		for i, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("Statistics", 1, true) then
				vim.api.nvim_win_set_cursor(0, { i, (line:find("Statistics", 1, true)) })
				row = i
			end
		end
		menu.view.cursor = nil
		vim.api.nvim_exec_autocmds("CursorMoved", { buffer = menu.win.buf })
		reactive.flush()
	]])
	-- The tile lifts its title into the accent color.
	child.lua([[
		lit = nil
		local buf, ns = menu.win.buf, menu.view.ns
		for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, { row - 1, 0 }, { row - 1, -1 }, { details = true })) do
			local text = vim.api.nvim_buf_get_text(buf, mark[2], mark[3], mark[2], mark[4].end_col, {})[1]
			if vim.trim(text) == "Statistics" then lit = mark[4].hl_group end
		end
	]])
	eq(child.lua_get("lit"), "leetcode_accent")
end

local function open_stats()
	open(true)
	child.type_keys("s")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
end

T["problems"] = new_set()

--- Creates solutions in the storage, each an hour older than the one before.
local function worked_on(problems)
	child.lua(([[
		_G.cached_problems = %s
		local home = require("leetcode.config").storage.home
		for i, problem in ipairs(_G.cached_problems) do
			local path = ("%%s/%%s.%%s.py"):format(home, problem.frontend_id, problem.title_slug)
			vim.fn.writefile({ "x" }, path)
			local time = os.time() - i * 3600
			vim.uv.fs_utime(path, time, time)
		end
	]]):format(problems))
end

local two_problems = [[{
	{ title = "Two Sum", title_cn = "", title_slug = "two-sum", frontend_id = "1", difficulty = "Easy", status = "ac" },
	{ title = "3Sum", title_cn = "", title_slug = "3sum", frontend_id = "15", difficulty = "Medium", status = "notac" },
}]]

local function open_problems()
	open(true)
	child.type_keys("p")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
end

T["problems"]["slide in with their buttons"] = function()
	open_problems()
	eq(child.lua_get("menu.page()"), "menu.problems")
	eq(contains("Random"), true)
	eq(contains("Daily challenge"), true)
	eq(contains("browse, random, recent"), false)
end

T["problems"]["say when nothing was worked on"] = function()
	open_problems()
	eq(contains("Problems you work on will show up here"), true)
end

T["problems"]["show recent work with its status, newest first"] = function()
	worked_on(two_problems)
	open_problems()
	eq(contains("1. Two Sum"), true)
	eq(contains("Solved · Easy · 1h ago"), true)
	eq(contains("15. 3Sum"), true)
	eq(contains("Attempted · Medium · 2h ago"), true)

	child.lua([[
		for i, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("1. Two Sum", 1, true) then first = i end
			if line:find("15. 3Sum", 1, true) then second = i end
		end
	]])
	eq(child.lua_get("first < second"), true)
end

T["problems"]["color recent work by what it means"] = function()
	worked_on(two_problems)
	open_problems()

	local function hl_of(text)
		return child.lua_get(([[(function()
			local buf, ns = menu.win.buf, menu.view.ns
			for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })) do
				local found = vim.api.nvim_buf_get_text(buf, mark[2], mark[3], mark[4].end_row or mark[2], mark[4].end_col, {})[1]
				if found == %q then
					return mark[4].hl_group
				end
			end
		end)()]]):format(text))
	end

	eq(hl_of("Solved"), "leetcode_easy")
	eq(hl_of("Attempted"), "leetcode_medium")
	eq(hl_of("Easy"), "leetcode_easy")
	eq(hl_of("Medium"), "leetcode_medium")
	eq(hl_of("1h ago"), "leetcode_muted")
	eq(hl_of("Two Sum"), "leetcode_strong")
end

T["problems"]["open recent work with its number"] = function()
	worked_on(two_problems)
	open_problems()
	child.lua([[
		opened = nil
		package.loaded["leetcode.cmd"].open = function(problem) opened = problem.title_slug end
	]])
	child.type_keys("2")
	eq(child.lua_get("opened"), "3sum")
end

T["problems"]["list only as much as fits"] = function()
	child.lua([[
		local items = {}
		for i = 1, 8 do
			items[i] = {
				title = "Problem " .. i, title_cn = "", title_slug = "problem-" .. i,
				frontend_id = tostring(i), difficulty = "Easy", status = "todo",
			}
		end
		problems_json = vim.inspect(items)
	]])
	worked_on(child.lua_get("problems_json"))
	open_problems()
	eq(contains("5. Problem 5"), true)
	eq(contains("6. Problem 6"), false)
end

T["problems"]["cut long titles"] = function()
	worked_on([[{
		{ title = "Longest Substring Without Repeating Characters In A String", title_cn = "",
		  title_slug = "long", frontend_id = "3", difficulty = "Medium", status = "ac" },
	}]])
	open_problems()
	eq(contains("…"), true)
end

T["problems"]["keep their keys after the slide"] = function()
	open(true)
	child.lua([[
		Markup.animate.enabled = true
		Markup.animate.manual = true
		browsed = false
		require("leetcode.ui.browser").open = function() browsed = true end
	]])
	child.type_keys("p")
	child.lua([[
		reactive.flush()
		Markup.animate.tick(3000)
		reactive.flush()
		reactive.flush()
	]])
	child.type_keys("p")
	eq(child.lua_get("browsed"), true)
end

T["problems"]["q goes back"] = function()
	open_problems()
	child.type_keys("q")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
	eq(child.lua_get("menu.page()"), "menu")
	eq(contains("progress and skills"), true)
end

T["problems"]["the menu keeps its keys after coming back"] = function()
	open_problems()
	child.type_keys("q")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
	child.type_keys("s")
	child.lua("reactive.flush()")
	eq(child.lua_get("menu.page()"), "menu.statistics")
end

T["statistics"] = new_set()

T["statistics"]["replace the dashboard"] = function()
	open_stats()
	eq(child.lua_get("menu.page()"), "menu.statistics")
	eq(contains("Statistics"), true)
	eq(contains("Fundamental"), true)
	eq(contains("progress and skills"), false)
end

T["statistics"]["show skills by level, most solved first"] = function()
	open(true)
	child.lua([[
		package.loaded["leetcode.api.stats"].skills = function(cb)
			cb({
				fundamental = { { tag = "Array", problems_solved = 2 }, { tag = "String", problems_solved = 9 } },
				intermediate = {},
				advanced = {},
			})
		end
	]])
	child.type_keys("s")
	child.lua([[
		vim.wait(50, function() reactive.flush(); return false end, 5)
		for i, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("String", 1, true) then string_row = i end
			if line:find("Array", 1, true) then array_row = i end
		end
	]])
	eq(child.lua_get("string_row < array_row"), true)
	eq(contains("Nothing yet"), true)
end

T["statistics"]["count what does not fit"] = function()
	open(true)
	child.lua([[
		local many = {}
		for i = 1, 9 do many[i] = { tag = "Tag " .. i, problems_solved = 10 - i } end
		package.loaded["leetcode.api.stats"].skills = function(cb)
			cb({ fundamental = many, intermediate = {}, advanced = {} })
		end
	]])
	child.type_keys("s")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
	eq(contains("Tag 6"), true)
	eq(contains("Tag 7"), false)
	eq(contains("+3 more"), true)
end

T["statistics"]["show languages, most solved first"] = function()
	open_stats()
	eq(contains("Languages"), true)
	child.lua([[
		for i, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("12", 1, true) and line:find("█", 1, true) then python = i end
			if line:find("C++", 1, true) then cpp = i end
		end
	]])
	eq(child.lua_get("python ~= nil and python < cpp"), true)
end

T["statistics"]["survive a user without languages"] = function()
	open(true)
	child.lua([[
		package.loaded["leetcode.api.stats"].languages = function(cb) cb(vim.NIL) end
	]])
	child.type_keys("s")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
	eq(contains("Nothing yet"), true)
end

T["statistics"]["q goes back to where the menu was"] = function()
	open_stats()
	child.type_keys("q")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
	eq(child.lua_get("menu.page()"), "menu")
	eq(contains("progress and skills"), true)
	eq(contains("Fundamental"), false)
	eq(contains("Problems"), true)
end

T["statistics"]["update fetches everything again"] = function()
	open_stats()
	child.lua("fetches = streak_fetches")
	child.type_keys("u")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
	eq(child.lua_get("streak_fetches > fetches"), true)
end

T["statistics"]["are fetched once, until updated"] = function()
	open(true)
	child.lua([[
		fetched = 0
		local stats = package.loaded["leetcode.api.stats"]
		local skills = stats.skills
		stats.skills = function(cb)
			fetched = fetched + 1
			skills(cb)
		end
		package.loaded["leetcode.ui.menu.data"].skills(nil)
	]])

	local function wait()
		child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
	end

	child.type_keys("s")
	wait()
	child.type_keys("q")
	wait()
	child.type_keys("s")
	wait()
	eq(child.lua_get("fetched"), 1)

	child.type_keys("u")
	wait()
	eq(child.lua_get("fetched"), 2)
end

T["statistics"]["move between the buttons sideways"] = function()
	open_stats()
	child.lua([[
		for i, line in ipairs(buffer_text(menu.win.buf)) do
			local col = line:find("Update", 1, true)
			if col then vim.api.nvim_win_set_cursor(0, { i, col - 2 }) end
		end
		menu.view.cursor = nil
		menu.view:snap_cursor()
	]])

	local function under_cursor()
		return child.lua_get(
			"vim.api.nvim_get_current_line():sub(vim.fn.col('.')):match('^%s*(%a+)')"
		)
	end

	eq(under_cursor(), "Update")
	child.type_keys("l")
	eq(under_cursor(), "Back")
	child.type_keys("l")
	eq(under_cursor(), "Back")
	child.type_keys("h")
	eq(under_cursor(), "Update")
end

T["statistics"]["update in the page, not in a notification"] = function()
	open_stats()
	child.lua([[
		require("leetcode.logger.spinner").start = function() error("no notifications") end
		local stats = package.loaded["leetcode.api.stats"]
		local skills = stats.skills
		stats.skills = function(cb) held = function() skills(cb) end end
	]])
	child.type_keys("u")
	child.lua("reactive.flush()")
	eq(contains("Updating"), true)
	eq(contains("Update u"), false)

	child.lua("held(); reactive.flush()")
	eq(contains("Updated"), true)

	child.lua("vim.wait(1700, function() reactive.flush(); return false end, 20)")
	eq(contains("Update u"), true)
end

T["statistics"]["a second update waits for the first"] = function()
	open_stats()
	child.lua([[
		count = 0
		local stats = package.loaded["leetcode.api.stats"]
		stats.skills = function(cb) count = count + 1; held = cb end
	]])
	child.type_keys("u")
	child.type_keys("u")
	eq(child.lua_get("count"), 1)
end

T["statistics"]["update finishes even when something fails"] = function()
	open_stats()
	child.lua([[
		vim.notify = function() end
		package.loaded["leetcode.api.stats"].languages = function(cb) cb(nil, { msg = "offline" }) end
	]])
	child.type_keys("u")
	child.lua("reactive.flush()")
	eq(contains("Updated"), true)
end

T["statistics"]["every block is a stop for the cursor"] = function()
	open_stats()
	child.lua("stops = {}")
	for _ = 1, 12 do
		child.lua([[
			local id = menu.view.hovered
			if id and not vim.tbl_contains(stops, id) then stops[#stops + 1] = id end
		]])
		child.type_keys("j")
	end
	-- Solved, the year, skills and languages.
	eq(child.lua_get("#stops"), 4)

	-- Up above them, the buttons of the page.
	for _ = 1, 12 do
		child.type_keys("k")
	end
	eq(child.lua_get("vim.api.nvim_get_current_line():find('Update', 1, true) ~= nil"), true)
end

T["statistics"]["a block lifts while the cursor is on it"] = function()
	open_stats()
	child.lua([[
		local function lifted()
			local buf, ns = menu.win.buf, menu.view.ns
			local row = vim.api.nvim_win_get_cursor(0)[1] - 1
			for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, { row, 0 }, { row, -1 }, { details = true })) do
				local group = mark[4].hl_group or ""
				if group:find("MarkupAnimated", 1, true) then
					return vim.api.nvim_get_hl(0, { name = group, link = false }).bg
				end
			end
		end
		lifted_now = lifted
		active = vim.api.nvim_get_hl(0, { name = "leetcode_row_active", link = false }).bg
	]])
	child.type_keys("j", "j")
	eq(child.lua_get("lifted_now()"), child.lua_get("active"))
end

T["statistics"]["open no popups"] = function()
	open(true)
	child.lua("wins = #vim.api.nvim_list_wins()")
	child.type_keys("s")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
	eq(child.lua_get("#vim.api.nvim_list_wins()"), child.lua_get("wins"))
end

T["statistics"]["slide in and out"] = function()
	open(true)
	child.lua([[
		Markup.animate.enabled = true
		Markup.animate.manual = true
	]])
	child.type_keys("s")
	child.lua([[
		reactive.flush()
		Markup.animate.tick(160)
		reactive.flush()
		reactive.flush()
	]])
	eq(child.lua_get("Markup.animate.running()"), true)
	child.lua([[
		Markup.animate.tick(3000)
		reactive.flush()
		reactive.flush()
	]])
	eq(contains("Fundamental"), true)
	eq(contains("progress and skills"), false)
end

T["continue"] = new_set()

T["continue"]["shows the last problem worked on"] = function()
	worked_on(two_problems)
	open(true)
	eq(contains("Continue"), true)
	eq(contains("1. Two Sum"), true)
	eq(contains("Solved · Easy · 1h ago"), true)
end

T["continue"]["opens it with c"] = function()
	worked_on(two_problems)
	open(true)
	child.lua([[
		opened = nil
		require("leetcode.cmd").open = function(problem) opened = problem.title_slug end
	]])
	child.type_keys("c")
	eq(child.lua_get("opened"), "two-sum")
end

T["continue"]["stays away before any work"] = function()
	open(true)
	eq(contains("Continue"), false)
end

T["problems"]["refresh the problem list"] = function()
	open_problems()
	child.lua([[
		refreshed = false
		require("leetcode.cmd").cache_update = function() refreshed = true end
	]])
	child.type_keys("r")
	eq(child.lua_get("refreshed"), true)
end

T["statistics"]["show what was solved and when"] = function()
	open_stats()
	eq(contains("20/100"), true)
	eq(contains("submissions"), true)
end

T["every module loads"] = function()
	local failed = child.lua_get([[(function()
		local failed = {}
		local skip = { telescope = true, fzf = true, snacks = true, mini = true }
		for _, file in ipairs(vim.fn.glob("lua/leetcode/**/*.lua", true, true)) do
			local name = file:gsub("^lua/", ""):gsub("%.lua$", ""):gsub("/init$", ""):gsub("/", ".")
			if not skip[name:match("[^.]+$")] then
				local ok, err = pcall(require, name)
				if not ok then
					failed[#failed + 1] = name .. ": " .. tostring(err):sub(1, 120)
				end
			end
		end
		return failed
	end)()]])
	eq(failed, {})
end

T["refresh fetches the stats again"] = function()
	open(true)
	child.lua([[
		before = streak_fetches
		menu.refresh()
		reactive.flush()
	]])
	eq(child.lua_get("streak_fetches == before + 1"), true)
end

T["titles follow the page"] = function()
	open(true)
	child.lua([[menu.set_page("menu.cookie"); reactive.flush()]])
	eq(contains("Account"), true)
	eq(contains("Sign out"), true)
end

return T
