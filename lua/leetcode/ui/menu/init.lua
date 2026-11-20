local m = require("markup")
local i18n = require("leetcode.i18n")
local cookie = require("leetcode.cache.cookie")
local kit = require("leetcode.ui.kit")
local Nav = require("leetcode.ui.menu.nav")
local Band = require("leetcode.ui.menu.dashboard.band")
local focus = require("leetcode.ui.menu.dashboard.focus")
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
	-- What was lit belongs to the page being left.
	focus.current(nil)
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

--- Below this the pages stack into one column, such as beside the browser.
local WIDE = 80
local WIDTH = 78
local NARROW = 46

--- Wide enough for the launcher, which keeps one width whatever the window.
local LAUNCHER = 50

--- The dashboard stands its cards and tiles side by side from here, at
--- `DASHBOARD` wide, and stacks them below it.
local DASHBOARD_WIDE = 96
local DASHBOARD = 90
local DASHBOARD_NARROW = 74

--- How wide the dashboard is, and whether its cards and tiles stand side by side.
---@return integer width
---@return boolean columns
function M.dashboard_width()
	local width = M.width()
	if width >= DASHBOARD_WIDE then
		return DASHBOARD, true
	end
	return math.max(math.min(width - 4, DASHBOARD_NARROW), 40), false
end

local Home = m.component(function()
	M.dashboards = M.dashboards + 1

	return m.vflex({
		align = "center",
		margin_top = 1,
		function()
			if M.home_page() ~= "menu" then
				return m.block({ margin_top = 1, width = LAUNCHER, Nav({ width = LAUNCHER }) })
			end
			local width, columns = M.dashboard_width()
			return m.block({ width = width, Nav({ width = width, columns = columns }) })
		end,
	})
end)

--- Everything before there is a user.
local Gate = m.component(function()
	M.dashboards = 0

	return m.vflex({
		align = "center",
		margin_top = 2,
		Band({ width = LAUNCHER }),
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
		margin_top = math.max(math.floor((vim.o.lines - 28) / 2), 1),
		m.show(gated, Gate, function()
			return m.vflex({
				align = "center",
				function()
					local width, columns = M.dashboard_width()
					return Band({ width = width, compact = not columns })
				end,
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
