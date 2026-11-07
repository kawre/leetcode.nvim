local H = {}

--- Loads the plugin in a child Neovim with the network replaced by fixtures.
function H.boot(child)
	child.restart({ "-u", "tests/init.lua" })
	child.o.lines, child.o.columns = 45, 120
	child.lua([[
		m = require("markup")
		reactive = require("markup.reactive")

		_G.Leet = setmetatable({ active_problems = {} }, {
			__index = function(t, k)
				t[k] = require("leetcode." .. k)
				return rawget(t, k)
			end,
		})

		-- Never touch the real storage.
		local root = vim.fn.tempname()
		vim.fn.mkdir(root .. "/home", "p")
		vim.fn.mkdir(root .. "/cache", "p")

		local config = require("leetcode.config")
		config.apply({ lang = "python3", storage = { home = root .. "/home", cache = root .. "/cache" } })
		config.setup()
		require("leetcode.theme").setup()

		package.loaded["leetcode.cache.cookie"] = { get = function() return _G.cookie end }

		local user = { name = "tester", id = 1, is_signed_in = true, is_verified = true }
		package.loaded["leetcode.api.auth"] = {
			user = function(cb)
				Leet.auth(user)
				vim.schedule(function() cb(user) end)
			end,
		}

		package.loaded["leetcode.api.stats"] = {
			session_progress = function(cb)
				cb({ { difficulty = "Easy", count = 12 }, { difficulty = "Medium", count = 7 } })
			end,
			streak = function(cb)
				_G.streak_fetches = (_G.streak_fetches or 0) + 1
				cb({ streakCount = 42, todayCompleted = true })
			end,
			solved = function(cb)
				cb({
					submit_stats = { acSubmissionNum = {
						{ difficulty = "All", count = 30 }, { difficulty = "Easy", count = 20 },
						{ difficulty = "Medium", count = 8 }, { difficulty = "Hard", count = 2 },
					} },
					questions_count = {
						{ difficulty = "All", count = 300 }, { difficulty = "Easy", count = 100 },
						{ difficulty = "Medium", count = 150 }, { difficulty = "Hard", count = 50 },
					},
				})
			end,
			skills = function(cb)
				cb({
					advanced = { { tag = "Dynamic Programming", problems_solved = 5 } },
					intermediate = { { tag = "Hash Table", problems_solved = 9 } },
					fundamental = { { tag = "Array", problems_solved = 20 } },
				})
			end,
			languages = function(cb)
				cb({ { lang = "Python3", problems_solved = 12 }, { lang = "C++", problems_solved = 1 } })
			end,
			calendar = function(cb)
				local now = os.time()
				cb({ calendar = { submission_calendar = { [tostring(now)] = 3 } } })
			end,
		}

		package.loaded["leetcode.cache.problems"] = {
			change_status = function(slug, status)
				_G.status_change = { slug, status }
			end,
			by_slug = function(slug)
				return {
					title_slug = slug, frontend_id = 15, title = "3Sum", title_cn = "3Sum",
					difficulty = "Medium", link = "https://leetcode.com/problems/" .. slug,
				}
			end,
		}

		fixture = {
			cached = { status = "ac", link = "https://leetcode.com/problems/two-sum/", title_slug = "two-sum" },
			problem = {
				id = "1", frontend_id = "1", title = "Two Sum", title_slug = "two-sum",
				translated_title = vim.NIL, translated_content = vim.NIL,
				difficulty = "Easy", likes = 100, dislikes = 2, is_paid_only = false,
				stats = { acRate = "50%", totalSubmission = "10M" },
				hints = { "Try a <code>hash map</code>." },
				topic_tags = { { name = "Array" } },
				similar = { { title_slug = "3sum", paid_only = false } },
				code_snippets = { { lang_slug = "python3", code = "class Solution:\n    pass\n" } },
				testcase_list = { "[2,7]\n9", "[3,3]\n6" },
				meta_data = { params = { { name = "nums", type = "integer[]" }, { name = "target", type = "integer" } } },
				content = [=[
<p>Given an array of integers <code>nums</code> and an integer <code>target</code>, return <em>indices of the two numbers</em> such that they add up to <code>target</code>, and this sentence is long enough that it has to wrap inside the window.</p>

<p>See <a href="https://example.com/docs">the docs</a> for more.</p>

<p><strong class="example">Example 1:</strong></p>

<pre>
<strong>Input:</strong> nums = [2,7,11,15], target = 9
<strong>Output:</strong> [0,1]
</pre>

<p><strong>Constraints:</strong></p>

<ul>
	<li><code>2 &lt;= nums.length &lt;= 10<sup>4</sup></code></li>
	<li>Only one valid answer exists, and this list item is also long enough that it wraps onto a second line of the pane.</li>
</ul>

<ol>
	<li>First</li>
	<li>Second</li>
</ol>

<table><thead><tr><th>id</th><th>name</th></tr></thead><tbody><tr><td>1</td><td>Joe</td></tr></tbody></table>
]=],
			},
		}

		function open_problem()
			vim.cmd("enew")
			problem = Leet.problem(fixture.cached, fixture.problem)
			reactive.flush()
			return problem
		end

		function buffer_text(buf)
			return vim.tbl_map(function(line)
				return (line:gsub("%s+$", ""))
			end, vim.api.nvim_buf_get_lines(buf, 0, -1, false))
		end

		function contains(buf, text)
			for _, line in ipairs(buffer_text(buf)) do
				if line:find(text, 1, true) then
					return true
				end
			end
			return false
		end
	]])
end

return H
