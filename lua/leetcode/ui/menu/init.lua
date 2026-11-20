local m = require("markup")
local cookie = require("leetcode.cache.cookie")
local kit = require("leetcode.ui.kit")
local Nav = require("leetcode.ui.menu.nav")
local Summary = require("leetcode.ui.menu.summary")
local data = require("leetcode.ui.menu.data")
local Stats = require("leetcode.ui.menu.stats")
local Problems = require("leetcode.ui.menu.problems")

--- Pages that are not part of the navigation, but slide in beside it.
local SLIDES = { ["menu.statistics"] = "stats", ["menu.problems"] = "problems" }

---@class leet.menu
local M = {
	page = m.signal("loading"),
	--- The page of the navigation, which stays put while statistics are open.
	home_page = m.signal("loading"),
	stats_version = m.signal(0),
	width = m.signal(vim.o.columns),
	rows = 0,
	rows_enter = true,
	dashboards = 0,
	win = Markup.window({
		position = "current",
		hijack = true,
		show = false,
	}),
}

Leet.menu = M

---@param page string
function M.set_page(page)
	if not SLIDES[page] then
		M.home_page(page)
	end
	M.page(page)
end

--- Whether the dashboard already played its intro. Reflowing mounts it again,
--- and that should not look like opening it for the first time.
---@return boolean
function M.settled()
	return M.dashboards > 1
end

--- Fetches the stats shown around the menu again.
function M.refresh()
	M.stats_version(function(version)
		return version + 1
	end)
end

local function sign_in()
	if not cookie.get() then
		return M.set_page("signin")
	end

	M.set_page("loading")

	require("leetcode.api.auth").user(function(_, err)
		if err then
			M.set_page("signin")
			Markup.log.error(err)
		else
			M.set_page("menu")
		end
	end)
end

--- Below this the dashboard stacks into one column, such as beside the browser.
local WIDE = 80
local WIDTH = 78
local NARROW = 46

--- Wide enough for the launcher, which keeps one width whatever the window.
local LAUNCHER = 50

local function greeting()
	local hour = tonumber(os.date("%H"))
	return hour < 5 and "night" or hour < 12 and "morning" or hour < 18 and "afternoon" or "evening"
end

--- The name, and who is here with how long their streak is.
local Brand = m.component(function()
	local streak = kit.counter(function()
		return data.streak().streakCount
	end, { duration = 1100, instant = M.settled() })

	return m.vflex({
		align = "center",
		m.block({
			m.inline(kit.icons.code .. " ", "leetcode_accent"),
			m.inline("leetcode.nvim", "leetcode_strong"),
		}),
		m.block(function()
			local auth = Leet.auth()
			if not auth then
				return nil
			end

			return m.inline({
				m.inline(("Good %s, %s"):format(greeting(), auth.name), "leetcode_muted"),
				data.streak().streakCount and m.inline({
					m.inline(" · ", "leetcode_muted"),
					m.inline({
						style = function()
							return data.streak().todayCompleted and "leetcode_flame"
								or "leetcode_flame_off"
						end,
						kit.icons.fire .. " ",
					}),
					m.inline(function()
						return tostring(math.floor(streak() + 0.5))
					end, "leetcode_strong"),
				}),
			})
		end),
	})
end)

local Home = m.component(function()
	M.dashboards = M.dashboards + 1

	return m.vflex({
		align = "center",
		margin_top = 2,
		m.block({ width = LAUNCHER, Nav({ width = LAUNCHER }) }),
		m.block({ margin_top = 2, Summary() }),
	})
end)

--- Everything before there is a user.
local Gate = m.component(function()
	M.dashboards = 0

	return m.vflex({
		align = "center",
		margin_top = 4,
		Brand(),
		m.block({ margin_top = 2, width = LAUNCHER, Nav({ width = LAUNCHER }) }),
	})
end)

local App = m.component(function()
	local view = m.use_view()

	m.use_key("<CR>", function()
		view:press()
	end)

	sign_in()

	m.effect(function()
		M.stats_version()
		if Leet.auth() then
			m.untrack(data.load)
		end
	end)

	local gated = m.memo(function()
		local page = M.page()
		return page == "loading" or page == "signin"
	end)

	local wide = m.memo(function()
		return M.width() >= WIDE
	end)

	return m.block({
		margin_top = math.max(math.floor((vim.o.lines - 26) / 2), 1),
		m.show(gated, Gate, function()
			return m.block({
				Brand(),
				m.slide(function()
					return SLIDES[M.page()] or "home"
				end, function(key)
					if key == "home" then
						return Home()
					end
					local Page = key == "stats" and Stats or Problems
					return function()
						return Page({ width = wide() and WIDTH or NARROW, columns = wide() })
					end
				end, {
					forward = function(_, to)
						return to ~= "home"
					end,
				}),
			})
		end),
	})
end)

function M.render()
	if not M.view then
		M.view = Markup.view(M.win, { snap = true, hide_cursor = true })
		M.view:on_commit(function()
			if M.win:valid() then
				M.width(vim.api.nvim_win_get_width(M.win.win))
			end
		end)
	end
	M.width(vim.api.nvim_win_get_width(M.win.win))
	M.view:render(App())
end

return M
