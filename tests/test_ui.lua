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

T["kit"] = new_set()

T["kit"]["draws numbers three rows tall"] = function()
	child.lua([[kit = require("leetcode.ui.kit")]])
	eq(child.lua_get("kit.big_number(7)"), { "▀▀█", "  █", "  █" })
	eq(child.lua_get("#kit.big_number(42)[1]"), #"█ █ ▀▀█")
end

T["kit"]["cuts text to a width"] = function()
	child.lua([[kit = require("leetcode.ui.kit")]])
	eq(child.lua_get("kit.truncate('short', 10)"), "short")
	eq(child.lua_get("kit.truncate('a longer title', 8)"), "a longe…")
	eq(child.lua_get("vim.api.nvim_strwidth(kit.truncate('日本語のタイトルです', 7))<= 7"), true)
end

T["recent"] = new_set()

T["recent"]["says how long ago"] = function()
	child.lua([[recent = require("leetcode.ui.menu.recent")]])
	eq(child.lua_get("recent.ago(1000, 1030)"), "just now")
	eq(child.lua_get("recent.ago(1000, 1000 + 300)"), "5m ago")
	eq(child.lua_get("recent.ago(0, 7200)"), "2h ago")
	eq(child.lua_get("recent.ago(0, 3 * 86400)"), "3d ago")
	eq(child.lua_get("recent.ago(0, 15 * 86400)"), "2w ago")
end

T["recent"]["keeps the newest file of a problem"] = function()
	child.lua([[
		_G.cached_problems = { { title = "Two Sum", title_slug = "two-sum", frontend_id = "1" } }
		local home = require("leetcode.config").storage.home:absolute()
		for ext, age in pairs({ py = 100, cpp = 5 }) do
			local path = home .. "/1.two-sum." .. ext
			vim.fn.writefile({ "x" }, path)
			vim.uv.fs_utime(path, os.time() - age, os.time() - age)
		end
		items = require("leetcode.ui.menu.recent").list(5)
	]])
	eq(child.lua_get("#items"), 1)
	eq(child.lua_get("items[1].ext"), "cpp")
end

T["recent"]["finds solutions with a language in their name"] = function()
	child.lua([[
		_G.cached_problems = { { title = "Two Sum", title_slug = "two-sum", frontend_id = "1" } }
		local home = require("leetcode.config").storage.home:absolute()
		vim.fn.writefile({ "x" }, home .. "/1.two-sum.python2.py")
		items = require("leetcode.ui.menu.recent").list(5)
	]])
	eq(child.lua_get("#items"), 1)
	eq(child.lua_get("items[1].ext"), "py")
end

T["recent"]["skips files that are not solutions"] = function()
	child.lua([[
		_G.cached_problems = { { title = "Two Sum", title_slug = "two-sum", frontend_id = "1" } }
		local home = require("leetcode.config").storage.home:absolute()
		vim.fn.writefile({ "x" }, home .. "/notes.md")
		vim.fn.writefile({ "x" }, home .. "/9.unknown-problem.py")
		items = require("leetcode.ui.menu.recent").list(5)
	]])
	eq(child.lua_get("#items"), 0)
end

T["recent"]["is empty when the problems cannot be read"] = function()
	child.lua([[
		package.loaded["leetcode.cache.problems"].get = function() error("offline") end
		items = require("leetcode.ui.menu.recent").list(5)
	]])
	eq(child.lua_get("#items"), 0)
end

T["diff"] = new_set()

T["diff"]["marks only what differs"] = function()
	child.lua([[diff = require("leetcode.ui.problem.result.diff")]])
	eq(child.lua_get([[{ diff.split("[0,2]", "[0,1]") }]]), {
		{ { "[0,", false }, { "2", true }, { "]", false } },
		{ { "[0,", false }, { "1", true }, { "]", false } },
	})
end

T["diff"]["keeps equal text whole"] = function()
	child.lua([[diff = require("leetcode.ui.problem.result.diff")]])
	eq(child.lua_get([[{ diff.split("same", "same") }]]), { { { "same", false } }, { { "same", false } } })
end

T["diff"]["handles multibyte text and insertions"] = function()
	child.lua([[diff = require("leetcode.ui.problem.result.diff")]])
	eq(child.lua_get([[{ diff.split("日本", "日本語") }]]), {
		{ { "日本", false } },
		{ { "日本", false }, { "語", true } },
	})
end

T["diff"]["gives up on huge output"] = function()
	child.lua([[
		diff = require("leetcode.ui.problem.result.diff")
		huge = ("x"):rep(5000)
		a, b = diff.split(huge, huge .. "y")
	]])
	eq(child.lua_get("#a"), 1)
	eq(child.lua_get("a[1][2]"), false)
end

T["confetti"] = new_set()

T["confetti"]["cleans up after itself"] = function()
	child.lua([[
		Markup.animate.enabled = true
		Markup.animate.manual = true
		before = #vim.api.nvim_list_wins()
		require("leetcode.ui.confetti").burst()
		during = #vim.api.nvim_list_wins()
		Markup.animate.tick(5000)
		after = #vim.api.nvim_list_wins()
	]])
	eq(child.lua_get("during > before"), true)
	eq(child.lua_get("after"), child.lua_get("before"))
end

T["confetti"]["keeps the floats below it visible"] = function()
	child.lua([[
		Markup.animate.enabled = true
		Markup.animate.manual = true
		require("leetcode.ui.confetti").burst()
		wins = vim.tbl_filter(function(win)
			return vim.api.nvim_win_get_config(win).zindex == 250
		end, vim.api.nvim_list_wins())
	]])
	eq(child.lua_get("#vim.tbl_filter(function(win) local c = vim.api.nvim_win_get_config(win); return c.width ~= 1 or c.height ~= 1 end, wins)"), 0)
end

T["confetti"]["stays away with reduced motion"] = function()
	child.lua([[
		before = #vim.api.nvim_list_wins()
		require("leetcode.ui.confetti").burst()
	]])
	eq(child.lua_get("#vim.api.nvim_list_wins()"), child.lua_get("before"))
end

T["filter"] = new_set()

local problems = [[{
	{ title = "Two Sum", frontend_id = "1", difficulty = "Easy", status = "ac", paid_only = false },
	{ title = "3Sum", title_cn = "三数之和", frontend_id = "15", difficulty = "Medium", status = "notac", paid_only = false },
	{ title = "Paint House", frontend_id = "256", difficulty = "Medium", status = "todo", paid_only = true },
}]]

local function filtered(filters)
	child.lua(("filter = require('leetcode.ui.browser.filter'); problems = %s"):format(problems))
	return child.lua_get(([[vim.tbl_map(function(p) return p.frontend_id end, filter.apply(problems,
		vim.tbl_extend("force", { difficulty = "all", status = "all", free = false, query = "" }, %s)))]]):format(filters))
end

T["filter"]["keeps everything by default"] = function()
	eq(filtered("{}"), { "1", "15", "256" })
end

T["filter"]["by difficulty, status and premium"] = function()
	eq(filtered([[{ difficulty = "medium" }]]), { "15", "256" })
	eq(filtered([[{ status = "ac" }]]), { "1" })
	eq(filtered([[{ free = true }]]), { "1", "15" })
	eq(filtered([[{ difficulty = "medium", free = true }]]), { "15" })
end

T["filter"]["by words of the title, in any order, or the number"] = function()
	eq(filtered([[{ query = "sum two" }]]), { "1" })
	eq(filtered([[{ query = "SUM" }]]), { "1", "15" })
	eq(filtered([[{ query = "256" }]]), { "256" })
	eq(filtered([[{ query = "三数" }]]), { "15" })
	eq(filtered([[{ query = "nothing" }]]), {})
end

T["browser"] = new_set()

local function open_browser(count)
	child.lua(([[
		browser = require("leetcode.ui.browser")
		items = {}
		for i = 1, %d do
			items[i] = {
				title = "Problem " .. i, title_cn = "", title_slug = "p" .. i, frontend_id = tostring(i),
				difficulty = ({ "Easy", "Medium", "Hard" })[i %% 3 + 1], status = i %% 2 == 0 and "ac" or "todo",
				ac_rate = 50, paid_only = false,
			}
		end
		browser.open(items)
		reactive.flush()
	]]):format(count))
end

local function list_has(text)
	return child.lua_get(("contains(browser.list.buf, %q)"):format(text))
end

local function filters_have(text)
	return child.lua_get(("contains(browser.filters.buf, %q)"):format(text))
end

T["browser"]["lists problems beside the menu"] = function()
	open_browser(5)
	eq(list_has("Problem 3"), true)
	eq(filters_have("5 of 5"), true)
	eq(child.lua_get("vim.api.nvim_get_current_win() == browser.list.win"), true)
end

T["browser"]["keys filter from either window"] = function()
	open_browser(9)
	child.type_keys("e")
	child.lua("reactive.flush()")
	eq(filters_have("3 of 9"), true)
	eq(list_has("Problem 1"), false)

	child.type_keys("<Tab>")
	eq(child.lua_get("vim.api.nvim_get_current_win() == browser.filters.win"), true)
	child.type_keys("a")
	child.lua("reactive.flush()")
	eq(filters_have("9 of 9"), true)
end

T["browser"]["filters are reached with h and l"] = function()
	open_browser(9)
	child.lua([[
		browser.filters:focus()
		for i, line in ipairs(buffer_text(browser.filters.buf)) do
			local col = line:find("All", 1, true)
			if col then vim.api.nvim_win_set_cursor(0, { i, col - 2 }) end
		end
		browser.filters_view.cursor = nil
		browser.filters_view:snap_cursor()
	]])

	local function under_cursor()
		return child.lua_get("vim.api.nvim_get_current_line():sub(vim.fn.col('.')):match('^%s*(%a+)')")
	end

	eq(under_cursor(), "All")
	child.type_keys("l")
	eq(under_cursor(), "Easy")
	child.type_keys("l")
	eq(under_cursor(), "Medium")
	child.type_keys("h")
	eq(under_cursor(), "Easy")
	eq(filters_have("9 of 9"), true)
end

T["browser"]["hard has a key that leaves h alone"] = function()
	open_browser(9)
	child.type_keys("H")
	child.lua("reactive.flush()")
	eq(filters_have("3 of 9"), true)
end

T["browser"]["filters can be pressed"] = function()
	open_browser(9)
	child.lua([[
		browser.filters:focus()
		for i, line in ipairs(buffer_text(browser.filters.buf)) do
			local col = line:find("Solved", 1, true)
			if col then vim.api.nvim_win_set_cursor(0, { i, col }) end
		end
	]])
	child.type_keys("<CR>")
	child.lua("reactive.flush()")
	eq(filters_have("4 of 9"), true)
end

T["browser"]["search filters as you type"] = function()
	open_browser(30)
	child.type_keys("/", "2", "5")
	child.lua("vim.wait(20, function() reactive.flush(); return false end, 5)")
	eq(filters_have("1 of 30"), true)
	child.type_keys("<Esc>")
	eq(child.lua_get("vim.api.nvim_get_current_win() == browser.list.win"), true)
end

T["browser"]["says when nothing matches"] = function()
	open_browser(2)
	child.type_keys("/", "z", "z")
	child.lua("vim.wait(20, function() reactive.flush(); return false end, 5)")
	eq(list_has("No problems match"), true)
end

T["browser"]["enter opens the problem under the cursor"] = function()
	open_browser(3)
	child.lua([[
		opened = nil
		package.loaded["leetcode.cmd"] = { open = function(problem) opened = problem.title_slug end }
		vim.api.nvim_win_set_cursor(browser.list.win, { 2, 12 })
	]])
	child.type_keys("<CR>")
	eq(child.lua_get("opened"), "p2")
end

T["browser"]["mounts rows in batches"] = function()
	open_browser(1000)
	eq(child.lua_get("#buffer_text(browser.list.buf)"), 200)

	child.lua([[
		vim.api.nvim_win_set_cursor(browser.list.win, { 190, 12 })
		vim.api.nvim_exec_autocmds("CursorMoved", { buffer = browser.list.buf })
		reactive.flush()
	]])
	eq(child.lua_get("#buffer_text(browser.list.buf)"), 400)
end

T["browser"]["closes and opens again"] = function()
	open_browser(3)
	local wins = child.lua_get("#vim.api.nvim_list_wins()")
	child.type_keys("q")
	eq(child.lua_get("browser.is_open()"), false)
	eq(child.lua_get("#vim.api.nvim_list_wins()") < wins, true)

	child.lua("browser.open(items); reactive.flush()")
	eq(child.lua_get("browser.is_open()"), true)
	eq(list_has("Problem 2"), true)
end

T["picker"] = new_set()

local function picker_rows()
	return child.lua_get([[(function()
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local config = vim.api.nvim_win_get_config(win)
			if config.relative ~= "" and not config.focusable then
				return buffer_text(vim.api.nvim_win_get_buf(win))
			end
		end
	end)()]])
end

local function list_problems(options)
	child.lua(([[
		_G.cached_problems = {
			{ title = "Two Sum", title_cn = "", title_slug = "two-sum", frontend_id = "1", difficulty = "Easy", status = "ac", ac_rate = 55.1, paid_only = false },
			{ title = "3Sum", title_cn = "", title_slug = "3sum", frontend_id = "15", difficulty = "Medium", status = "todo", ac_rate = 35, paid_only = false },
			{ title = "Paint House", title_cn = "", title_slug = "paint-house", frontend_id = "256", difficulty = "Medium", status = "todo", ac_rate = 60, paid_only = true },
		}
		opened = nil
		Leet.cmd = { open = function(problem) opened = problem.title_slug end }
		require("leetcode.picker").question(_G.cached_problems, %s)
		reactive.flush()
	]]):format(options or "nil"))
end

T["picker"]["lists problems without a picker plugin"] = function()
	list_problems()
	local rows = picker_rows()
	eq(#rows, 3)
	eq(rows[1]:find("1. Two Sum", 1, true) ~= nil, true)
	eq(rows[1]:find("55.1%", 1, true) ~= nil, true)
	eq(child.fn.mode(), "i")
end

T["picker"]["finds problems by number"] = function()
	list_problems()
	child.type_keys("256")
	child.lua("reactive.flush()")
	local rows = picker_rows()
	eq(#rows, 1)
	eq(rows[1]:find("Paint House", 1, true) ~= nil, true)
end

T["picker"]["opens the chosen problem"] = function()
	list_problems()
	child.type_keys("3sum", "<CR>")
	eq(child.lua_get("opened"), "3sum")
end

T["picker"]["keeps leet list options"] = function()
	list_problems([[{ difficulty = { "medium" } }]])
	eq(#picker_rows(), 2)
end

T["picker"]["changes the language"] = function()
	child.lua([[
		changed = nil
		problem = {
			lang = "python3",
			problem = { code_snippets = { { lang_slug = "python3" }, { lang_slug = "cpp" } } },
			change_lang = function(_, slug) changed = slug end,
		}
		require("leetcode.picker").language(problem)
		reactive.flush()
	]])
	local rows = picker_rows()
	eq(#rows, 2)
	child.type_keys("c++", "<CR>")
	eq(child.lua_get("changed"), "cpp")
end

T["picker"]["switches between open problems"] = function()
	child.lua([[
		first = vim.api.nvim_get_current_tabpage()
		vim.cmd("tabnew")
		local function tab(tabpage, id, title)
			return { tabpage = tabpage, question = {
				lang = "python3",
				problem = { frontend_id = id, title = title, translated_title = vim.NIL, difficulty = "Easy" },
			} }
		end
		Leet.util.question_tabs = function()
			return { tab(first, "1", "Two Sum"), tab(vim.api.nvim_get_current_tabpage(), "15", "3Sum") }
		end
		require("leetcode.picker").tabs()
		reactive.flush()
	]])
	child.type_keys("two", "<CR>")
	eq(child.lua_get("vim.api.nvim_get_current_tabpage() == first"), true)
end

T["picker"]["needs no picker plugin"] = function()
	child.lua([[
		for _, name in ipairs({ "telescope", "fzf-lua", "snacks.picker", "mini.pick" }) do
			package.loaded[name] = nil
			package.preload[name] = function() error("not installed") end
		end
		_G.Snacks = nil
	]])
	list_problems()
	eq(#picker_rows(), 3)
end

T["browser"]["leet list still uses the picker"] = function()
	child.lua([[
		picked = false
		package.loaded["leetcode.picker"] = { question = function() picked = true end }
		package.loaded["leetcode.cache.problems"].get = function() return {} end
		package.loaded["leetcode.util"].auth_guard = function() end
		require("leetcode.cmd").problems()
	]])
	eq(child.lua_get("picked"), true)
end

return T
