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
	eq(contains("please sign in"), true)
end

T["signed in shows the main page"] = function()
	open(true)
	eq(child.lua_get("menu.page()"), "menu")
	eq(contains("Problems"), true)
	eq(contains("Statistics"), true)
	eq(contains("Exit"), true)
end

T["the dashboard follows the signed in user"] = function()
	open(true)
	eq(contains("tester"), true)
	eq(contains("day streak"), true)
	eq(contains("done for today"), true)
end

T["the daily challenge has a card"] = function()
	open(true)
	eq(contains("Daily challenge"), true)
	eq(contains("3Sum"), true)
	eq(contains("Medium"), true)
end

T["the dashboard stacks when it gets narrow"] = function()
	open(true)
	eq(contains("Daily challenge"), true)

	child.lua([[
		vim.cmd("vnew")
		vim.api.nvim_win_set_width(menu.win.win, 60)
		menu.view:request_commit()
		reactive.flush()
		reactive.flush()
	]])
	eq(contains("Daily challenge"), false)
	eq(contains("Problems"), true)
	eq(contains("Solved"), true)
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

T["reflowing keeps the data and skips the intro"] = function()
	open(true)
	child.lua([[
		Markup.animate.enabled = true
		Markup.animate.manual = true
		fetches = streak_fetches
		vim.cmd("vnew")
		vim.api.nvim_win_set_width(menu.win.win, 60)
		menu.view:request_commit()
		reactive.flush()
		reactive.flush()
	]])
	eq(contains("Solved"), true)
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
		return child.lua_get(("vim.api.nvim_get_current_line():find(%q, 1, true) ~= nil"):format(text))
	end

	child.type_keys("j")
	eq(on("Statistics"), true)
	child.type_keys("j")
	eq(on("Cookie"), true)
	child.type_keys("k")
	eq(on("Statistics"), true)
	child.type_keys("k")
	eq(on("Problems"), true)
end

T["navigation explains itself"] = function()
	open(true)
	eq(contains("Browse, filter and search"), true)
	eq(contains("Skills and languages"), true)
end

T["navigation comes first on the screen"] = function()
	open(true)
	child.lua([[
		for i, line in ipairs(buffer_text(menu.win.buf)) do
			if line:find("Problems", 1, true) and not nav then nav = i end
			if line:find("submissions", 1, true) and not calendar then calendar = i end
		end
	]])
	eq(child.lua_get("nav < calendar"), true)
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
	eq(child.lua_get("buffer_text(menu.win.buf)[row]:find('▌', 1, true) ~= nil"), true)
end

local function open_stats()
	open(true)
	child.type_keys("s")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
end

T["statistics"] = new_set()

T["statistics"]["replace the dashboard"] = function()
	open_stats()
	eq(child.lua_get("menu.page()"), "menu.statistics")
	eq(contains("Statistics"), true)
	eq(contains("Fundamental"), true)
	eq(contains("day streak"), false)
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
	eq(contains("day streak"), true)
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
	eq(contains("day streak"), false)
end

T["every module loads"] = function()
	local failed = child.lua_get([[(function()
		local failed = {}
		local skip = { telescope = true, fzf = true, snacks = true, mini = true }
		for _, file in ipairs(vim.fn.glob("lua/leetcode/**/*.lua", true, true)) do
			local name = file:gsub("^lua/", ""):gsub("%.lua$", ""):gsub("/init$", ""):gsub("/", ".")
			if not skip[name:match("[^.]+$")] then
				local ok, err = pcall(require, name)
				-- The tests run without a picker plugin, which is a valid refusal,
				-- and Lua reports it differently the second time around.
				local message = tostring(err)
				local refused = message:find("No picker is available", 1, true)
					or message:find("previous error loading module 'leetcode.picker'", 1, true)
				if not ok and not refused then
					failed[#failed + 1] = name .. ": " .. message:sub(1, 120)
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
	child.lua([[menu.set_page("menu.cache"); reactive.flush()]])
	eq(contains("Cache"), true)
end

return T
