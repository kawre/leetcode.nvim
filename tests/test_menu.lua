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
	return child.lua_get(([[(function()
		if contains(menu.win.buf, %q) then return true end
		-- The band and the header, pinned above in floats of their own.
		for _, fixed in ipairs(menu.view.fixed) do
			if contains(fixed.win.buf, %q) then return true end
		end
		return false
	end)()]]):format(text, text))
end

--- The line of the header, just above the page.
local function header()
	return child.lua_get([[(function()
		for _, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("Menu", 1, true) then return vim.trim(line) end
		end
		return ""
	end)()]])
end

--- The row the header is on.
local function header_row()
	return child.lua_get([[(function()
		for i, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("Menu", 1, true) then return i end
		end
	end)()]])
end

--- The line of the band, just above the header.
local function band()
	return child.lua_get([[(function()
		for _, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("leetcode.nvim", 1, true) then return vim.trim(line) end
		end
		return ""
	end)()]])
end

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

--- Puts the cursor on the first `text`, as a move of the user would.
local function cursor_to(text)
	child.lua(([[
		for i, line in ipairs(buffer_text(menu.win.buf)) do
			local col = line:find(%q, 1, true)
			if col then
				vim.api.nvim_win_set_cursor(0, { i, col })
				break
			end
		end
		menu.view.cursor = nil
		menu.view:snap_cursor()
		vim.api.nvim_exec_autocmds("CursorMoved", { buffer = menu.win.buf })
		reactive.flush()
	]]):format(text))
end

--- Moves with `keys`, and says what the dashboard lit after.
local function lit_after(keys)
	child.type_keys(keys)
	child.lua([[
		vim.api.nvim_exec_autocmds("CursorMoved", { buffer = menu.win.buf })
		reactive.flush()
	]])
	return child.lua_get([[(require("leetcode.ui.menu.dashboard.focus").current() or {}).id]])
end

--- The highlight of the first `text` on the line holding `on`.
local function hl_of(text, on)
	return child.lua_get(([[(function()
		local buf, ns = menu.win.buf, menu.view.ns
		for row, line in ipairs(buffer_text(buf)) do
			if line:find(%q, 1, true) then
				for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, { row - 1, 0 }, { row - 1, -1 }, { details = true })) do
					local got = vim.api.nvim_buf_get_text(buf, mark[2], mark[3], mark[2], mark[4].end_col, {})[1]
					if vim.trim(got) == %q then return mark[4].hl_group end
				end
			end
		end
	end)()]]):format(on, text))
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
	eq(contains("skills, heatmap"), true)
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
			local col = line:find("Statistics", 1, true)
			if col then
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
	local through =
		"reactive.flush(); Markup.animate.tick(3000); reactive.flush(); reactive.flush()"
	child.type_keys("p")
	child.lua(through)
	child.type_keys("q")
	child.lua(through)
	eq(contains("solved"), true)
	eq(child.lua_get("streak_fetches"), child.lua_get("fetches"))

	-- The row under the cursor may still fade in, but the intro takes far longer.
	child.lua("Markup.animate.tick(200)")
	eq(child.lua_get("Markup.animate.running()"), false)
end

T["the cursor only stops on cards and tiles"] = function()
	open(true)
	cursor_to("Problems")
	eq(lit_after("k"), "card.t")
	eq(lit_after("j"), "problems")
end

T["the selected row stands in for the cursor"] = function()
	open(true)
	eq(child.lua_get("vim.o.guicursor:find('MarkupHiddenCursor', 1, true) ~= nil"), true)

	child.cmd("tabnew")
	eq(child.lua_get("vim.o.guicursor:find('MarkupHiddenCursor', 1, true)"), vim.NIL)
end

T["h and l move between tiles, one press each"] = function()
	open(true)
	cursor_to("Problems")
	eq(lit_after("l"), "random")
	eq(lit_after("l"), "statistics")
	eq(lit_after("l"), "account")
	eq(lit_after("h"), "statistics")
	eq(lit_after("h"), "random")
	eq(lit_after("h"), "problems")
end

T["tiles stand side by side when wide, two by two when narrow"] = function()
	open(true)
	child.lua([[
		for _, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("Problems", 1, true) then tiles = line break end
		end
	]])
	eq(child.lua_get("tiles:find('Account', 1, true) ~= nil"), true)

	child.lua([[
		vim.cmd("vnew")
		vim.api.nvim_win_set_width(menu.win.win, 80)
		menu.view:request_commit()
		reactive.flush()
		reactive.flush()
		for _, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("Problems", 1, true) then tiles = line break end
		end
	]])
	eq(child.lua_get("tiles:find('Random', 1, true) ~= nil"), true)
	eq(child.lua_get("tiles:find('Statistics', 1, true) ~= nil"), false)
end

T["the header says where the menu is, and never moves"] = function()
	open(true)
	local row = header_row()
	eq(header():find("Menu", 1, true) ~= nil, true)
	eq(header():find("›", 1, true), nil)
	eq(header():find("Quit q", 1, true) ~= nil, true)

	child.lua(
		[[menu.set_page("menu.cookie"); vim.wait(50, function() reactive.flush(); return false end, 5)]]
	)
	eq(header():find("Menu › Account", 1, true) ~= nil, true)
	eq(header():find("Back q", 1, true) ~= nil, true)
	eq(header_row(), row)

	child.lua(
		[[menu.set_page("menu.statistics"); vim.wait(50, function() reactive.flush(); return false end, 5)]]
	)
	eq(header_row(), row)
end

T["a short window can still show the whole dashboard"] = function()
	child.o.lines = 14
	-- What many configs set, which used to undo every scroll.
	child.o.scrolloff = 8
	worked_on(two_problems)
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
	eq(child.lua_get("visible('2h ago')"), false)

	for _ = 1, 40 do
		child.type_keys("j")
	end
	eq(child.lua_get("visible('2h ago')"), true)

	for _ = 1, 60 do
		child.type_keys("k")
	end
	-- Back at the top, band and all.
	eq(child.lua_get("vim.fn.line('w0')"), 1)
	eq(child.lua_get("visible('leetcode.nvim')"), true)
end

T["navigation explains itself"] = function()
	open(true)
	eq(contains("browse, refresh"), true)
	eq(contains("skills, heatmap"), true)
end

T["the band holds the streak and the numbers"] = function()
	open(true)
	eq(band():find("42", 1, true) ~= nil, true)
	eq(band():find("30 solved", 1, true) ~= nil, true)
	eq(band():find("20 · 8 · 2", 1, true) ~= nil, true)
end

T["what the cursor is on lights up, and the rest steps back"] = function()
	open(true)
	cursor_to("Statistics")
	-- Its key fills in, the others step back.
	eq(hl_of("s", "Statistics"), "leetcode_tab_active")
	eq(hl_of("p", "Problems"), "leetcode_muted")
	eq(hl_of("Problems", "Problems"), "leetcode_soft")
	eq(hl_of("Statistics", "Statistics"), "leetcode_strong")
	-- A spine runs down its left edge, the whole height of the tile, and
	-- down no other.
	child.lua([[
		spine = {}
		for _, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("▎", 1, true) then
				spine[#spine + 1] = line
			end
		end
	]])
	eq(child.lua_get("#spine"), 4)
	eq(child.lua_get("spine[2]"):find("Statistics", 1, true) ~= nil, true)
	eq(child.lua_get("spine[2]"):match("▎%s*s%s+Statistics") ~= nil, true)
end

T["something is lit from the start"] = function()
	open(true)
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
	eq(
		child.lua_get([[(require("leetcode.ui.menu.dashboard.focus").current() or {}).id]]),
		"card.t"
	)
	eq(contains("▎"), true)
end

T["resizing the window keeps the dashboard in the middle"] = function()
	open(true)
	local function margins()
		child.lua("vim.wait(100, function() reactive.flush(); return false end, 5)")
		return child.lua_get([[(function()
			local rows = buffer_text(menu.win.buf)
			local top, bottom, left, right = nil, nil, 999, 0
			-- Below the band, where the dashboard is.
			for i = 4, #rows do
				local line = rows[i]
				if line:find("Daily challenge", 1, true) or line:find("Recent", 1, true) then
					top = top or i
					bottom = i
					left = math.min(left, #line:match("^%s*"))
					right = math.max(right, vim.fn.strdisplaywidth(line))
				end
			end
			return {
				above = top - 4,
				below = vim.api.nvim_win_get_height(0) - bottom,
				left = left,
				right = vim.api.nvim_win_get_width(0) - right,
			}
		end)()]])
	end

	for _, size in ipairs({ { 200, 60 }, { 110, 34 } }) do
		child.o.columns, child.o.lines = size[1], size[2]
		local got = margins()
		-- Even to within the rows and columns that cannot be split in two.
		eq(math.abs(got.above - got.below) <= 4, true)
		eq(math.abs(got.left - got.right) <= 2, true)
	end
end

T["the band sits just above the header, as wide as the dashboard"] = function()
	open(true)
	child.lua([[
		lines = buffer_text(menu.win.buf)
		for i, line in ipairs(lines) do
			if line:find("leetcode.nvim", 1, true) then band_row = i end
			if line:find("Menu", 1, true) then header_row = i end
		end
	]])
	-- Its line, its lower edge and a blank row, then the header.
	eq(child.lua_get("header_row - band_row"), 3)
	local width = child.lua_get("vim.fn.strdisplaywidth(vim.trim(lines[band_row - 1]))")
	eq(width, child.lua_get("(menu.dashboard_width())"))
	-- In the middle, not along the top of the window.
	eq(child.lua_get("band_row") > 2, true)
end

T["the band follows signing in that ends after it shows"] = function()
	child.lua([[
		local user = { name = "late", id = 1, is_signed_in = true, is_verified = true }
		package.loaded["leetcode.api.auth"].user = function(cb)
			vim.defer_fn(function()
				Leet.auth(user)
				cb(user)
			end, 50)
		end
	]])
	open(true)
	child.lua("vim.wait(300, function() reactive.flush(); return menu.page() == 'menu' end, 5)")
	child.lua("reactive.flush()")
	eq(contains("not signed in"), false)
	eq(contains("late"), true)
end

T["a long name leaves the band before anything overlaps"] = function()
	open(true)
	child.lua([[
		Leet.auth().name = ("x"):rep(60)
		vim.cmd("vnew")
		vim.api.nvim_win_set_width(menu.win.win, 100)
		menu.view:request_commit()
		reactive.flush()
		reactive.flush()
	]])
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
	eq(band():find("xxxx", 1, true), nil)
	eq(band():find("20 · 8 · 2", 1, true) ~= nil, true)
end

T["the line below the tiles says what Enter does"] = function()
	open(true)
	cursor_to("Random")
	eq(contains("\u{f0cfd} Random  opens a problem at random"), true)
	cursor_to("Account")
	eq(contains("your session cookie, and signing out"), true)
end

T["r opens a random problem"] = function()
	open(true)
	child.lua([[
		random = false
		require("leetcode.cmd").random_question = function(_, task) random = true; task.done() end
	]])
	child.type_keys("r")
	eq(child.lua_get("random"), true)
end

T["q quits from the dashboard"] = function()
	open(true)
	child.lua([[
		stopped = false
		require("leetcode").stop = function() stopped = true end
	]])
	child.type_keys("q")
	eq(child.lua_get("stopped"), true)
end

T["signed out, the band says so"] = function()
	open(false)
	eq(contains("not signed in"), true)
end

local function open_stats()
	open(true)
	child.type_keys("s")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
end

T["problems"] = new_set()

local function open_problems()
	open(true)
	child.type_keys("p")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
end

T["problems"]["slide in with their buttons"] = function()
	open_problems()
	eq(child.lua_get("menu.page()"), "menu.problems")
	eq(contains("Random"), true)
	eq(contains("Daily"), true)
	eq(contains("Refresh"), true)
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
	-- The rows step back while a tile is lit, so the cursor goes to the first.
	cursor_to("Two Sum")

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
		{ title = "Longest Substring Without Repeating Characters In A String That Goes On And On For Ever", title_cn = "",
		  title_slug = "long", frontend_id = "3", difficulty = "Medium", status = "ac" },
	}]])
	open_problems()
	eq(contains("…"), true)
end

T["problems"]["keep their keys while animations run"] = function()
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
	eq(contains("skills, heatmap"), true)
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
	eq(contains("skills, heatmap"), true)
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

T["statistics"]["list update and back in the header"] = function()
	open_stats()
	eq(header():find("Menu › Statistics", 1, true) ~= nil, true)
	eq(header():find("Update u", 1, true) ~= nil, true)
	eq(header():find("Back q", 1, true) ~= nil, true)
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

	-- Back up, the first of them.
	for _ = 1, 12 do
		child.type_keys("k")
	end
	eq(child.lua_get("menu.view.hovered"), child.lua_get("stops[1]"))
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

T["statistics"]["take the dashboard's place at once"] = function()
	open(true)
	child.lua([[
		Markup.animate.enabled = true
		Markup.animate.manual = true
	]])
	local row = header_row()
	child.type_keys("s")
	child.lua("reactive.flush(); reactive.flush()")
	-- No page falls away first: the new one is there before any frame plays.
	eq(contains("Daily challenge"), false)
	eq(contains("Fundamental"), true)
	eq(header_row(), row)
	-- And the cursor is on it.
	eq(child.lua_get("vim.api.nvim_win_get_cursor(0)[1]") > row, true)
end

T["statistics"]["open no popups"] = function()
	open(true)
	child.lua("wins = #vim.api.nvim_list_wins()")
	child.type_keys("s")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
	eq(child.lua_get("#vim.api.nvim_list_wins()"), child.lua_get("wins"))
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

T["continue"]["recent work shows below the tiles, opened with its number"] = function()
	worked_on(two_problems)
	open(true)
	child.lua([[
		for i, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("Problems", 1, true) and not tiles then tiles = i end
			if line:find("2h ago", 1, true) then second = i end
		end
		opened = nil
		require("leetcode.cmd").open = function(problem) opened = problem.title_slug end
	]])
	eq(child.lua_get("tiles < second"), true)
	child.type_keys("2")
	eq(child.lua_get("opened"), "3sum")
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
	child.type_keys("u")
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
