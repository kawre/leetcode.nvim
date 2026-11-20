---@module 'mini.test'

--- Fetching never blocks: what starts it shows a loader until LeetCode
--- answers, and if what started it is gone by then, nothing happens.
---
--- LeetCode here answers only when a test says so, and any request that would
--- wait for it is an error.

local helpers = dofile("tests/helpers.lua")
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_case = function()
			helpers.boot(child)
			child.lua([[
				errors = {}
				vim.notify = function(message, level)
					if level == vim.log.levels.ERROR then errors[#errors + 1] = tostring(message) end
				end

				-- A loader that is the same every time, to look for.
				require("markup.view.components").loader_names = function() return { "dots" } end

				pending = {}
				Leet.api.query = function(query, variables, opts)
					if not (opts and opts.callback) then
						error("a request that waits: " .. vim.trim(query):sub(1, 30))
					end
					pending[#pending + 1] = { variables = variables, callback = opts.callback }
				end

				--- LeetCode answers the oldest request with the question it asked for.
				function answer()
					local request = table.remove(pending, 1)
					local q = vim.deepcopy(fixture.problem)
					q.title_slug = request.variables.titleSlug
					q.meta_data = vim.json.encode(q.meta_data)
					q.stats = vim.json.encode(q.stats)
					request.callback({ data = { question = q } }, nil)
					reactive.flush()
				end

				opened = {}
				Leet.problem = function(_, res) opened[#opened + 1] = res.title_slug end

				function corner()
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "leetcode.toast" then
							return table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false))
						end
					end
				end
			]])
		end,
		post_case = function()
			eq(child.lua_get("errors"), {})
		end,
		post_once = function()
			child.stop()
		end,
	},
})

local function run(code)
	child.lua(code)
end

local function get(code)
	return child.lua_get(code)
end

T["open"] = new_set()

T["open"]["comes back at once, with a loader in the corner"] = function()
	run([[
		require("leetcode.cmd").open({ title_slug = "two-sum", title = "Two Sum" })
		reactive.flush()
	]])
	eq(get("#pending"), 1)
	eq(get("opened"), {})
	eq(get("corner()"):find("Opening Two Sum", 1, true) ~= nil, true)

	run("answer()")
	eq(get("opened"), { "two-sum" })
	eq(get("corner()"), vim.NIL)
end

T["open"]["a second press while it is on its way fetches once"] = function()
	run([[
		local cmd = require("leetcode.cmd")
		cmd.open({ title_slug = "two-sum", title = "Two Sum" })
		cmd.open({ title_slug = "two-sum", title = "Two Sum" })
	]])
	eq(get("#pending"), 1)
	run("answer()")
	eq(get("opened"), { "two-sum" })
end

T["open"]["a task that is cancelled meanwhile opens nothing"] = function()
	run([[
		gone, finished = false, false
		require("leetcode.cmd").open({ title_slug = "two-sum", title = "Two Sum" }, {
			cancelled = function() return gone end,
			done = function() finished = true end,
		})
		gone = true
		answer()
	]])
	eq(get("opened"), {})
	eq(get("finished"), false)
	eq(get("corner()"), vim.NIL)
end

T["open"]["random waits for nothing either"] = function()
	run([[
		require("leetcode.util").auth_guard = function() end
		require("leetcode.cache.problems").by_slug = function(slug) return { title_slug = slug, title = slug } end
		require("leetcode.cmd").random_question()
		reactive.flush()
		drawing = corner()
		local request = table.remove(pending, 1)
		request.callback({ data = { randomQuestion = { title_slug = "two-sum", paid_only = false } } }, nil)
		reactive.flush()
	]])
	eq(get("drawing"):find("Picking a random problem", 1, true) ~= nil, true)
	-- The draw is done, the question itself is on its way.
	eq(get("#pending"), 1)
	run("answer()")
	eq(get("opened"), { "two-sum" })
	eq(get("corner()"), vim.NIL)
end

--- Opens the browser on a few problems, with its cursor on the first.
local function open_browser()
	run([[
		browser = require("leetcode.ui.browser")
		items = {}
		for i = 1, 5 do
			items[i] = {
				title = "Problem " .. i, title_cn = "", title_slug = "p" .. i, frontend_id = tostring(i),
				difficulty = "Easy", status = "todo", ac_rate = 50, paid_only = false,
			}
		end
		browser.open(items)
		reactive.flush()
	]])
end

local function list_has(text)
	return get(("contains(browser.list.buf, %q)"):format(text))
end

T["browser"] = new_set()

T["browser"]["the row pressed shows a loader until it opens"] = function()
	open_browser()
	eq(list_has("⠋"), false)
	child.type_keys("<CR>")
	run("reactive.flush()")
	eq(get("#pending"), 1)
	eq(list_has("⠋"), true)
	-- Its own loader, so none in the corner.
	eq(get("corner()"), vim.NIL)

	run("answer()")
	eq(get("opened"), { "p1" })
	eq(list_has("⠋"), false)
end

T["browser"]["pressing the row again does not fetch it twice"] = function()
	open_browser()
	child.type_keys("<CR>")
	child.type_keys("<CR>")
	eq(get("#pending"), 1)
end

T["browser"]["closed before the question arrives, it opens nothing"] = function()
	open_browser()
	child.type_keys("<CR>")
	run([[
		browser.close()
		reactive.flush()
		answer()
	]])
	eq(get("opened"), {})
end

T["sign in"] = new_set()

T["sign in"]["the menu says it is signing in while LeetCode checks the cookie"] = function()
	run([[
		menu = require("leetcode.ui.menu")
		menu.set_page("signin")
		checking = nil
		local cookie = require("leetcode.cache.cookie")
		cookie.set = function(_, cb) checking = cb end
		vim.ui.input = function(_, on_confirm) on_confirm("csrftoken=x; LEETCODE_SESSION=y") end
		require("leetcode.cmd").cookie_prompt()
		reactive.flush()
		while_checking = menu.page()
	]])
	eq(get("while_checking"), "loading")

	run([[
		checking("invalid cookie")
		reactive.flush()
	]])
	eq(get("menu.page()"), "signin")
	eq(get("errors[1]"):find("Sign-in failed: invalid cookie", 1, true) ~= nil, true)
	run("errors = {}")
end

return T
