local H = {}

--- Loads the plugin in a child Neovim with the network replaced by fixtures.
function H.boot(child)
	child.restart({ "-u", "tests/init.lua" })
	child.o.lines, child.o.columns = 45, 120
	child.lua([[
		m = require("markup")
		reactive = require("markup.reactive")

		_G.Leet = setmetatable({ ctx = {}, active_problems = {} }, {
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
		config.apply({ storage = { home = root .. "/home", cache = root .. "/cache" } })
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
			streak = function(cb) cb({ streakCount = 42, todayCompleted = true }) end,
			calendar = function(cb)
				local now = os.time()
				cb({ calendar = { submission_calendar = { [tostring(now)] = 3 } } })
			end,
		}

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
