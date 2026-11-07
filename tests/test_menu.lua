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

T["the footer follows the signed in user"] = function()
	open(true)
	eq(contains("tester"), true)
	eq(contains("42"), true)
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

T["the cursor only stops on buttons"] = function()
	open(true)
	child.lua([[
		local rows = buffer_text(menu.win.buf)
		for i, line in ipairs(rows) do
			if line:find("Problems", 1, true) then
				button_row = i
				vim.api.nvim_win_set_cursor(0, { i, #line:match("^%s*") })
			end
		end
		menu.view.cursor = nil
		menu.view:snap_cursor()
	]])
	child.type_keys("j")
	eq(child.lua_get("vim.api.nvim_win_get_cursor(0)[1] > button_row + 1"), true)
end

T["statistics shows solved progress"] = function()
	open(true)
	child.type_keys("s")
	child.lua("vim.wait(50, function() reactive.flush(); return false end, 5)")
	eq(child.lua_get("menu.page()"), "menu.statistics")
	eq(contains("30/300"), true)
	eq(contains("20/100"), true)
	eq(contains("Languages"), true)
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
