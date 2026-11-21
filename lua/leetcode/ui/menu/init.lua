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
	height = m.signal(vim.o.lines),
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

--- Wide enough for the sign-in card, which keeps one width whatever the window.
local LAUNCHER = 60

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

--- Rows of the band along the top.
local BAND = 3

--- About how tall what sits below the band is, to put it in the middle.
---@return integer
local function content_height()
	local page = M.page()
	if page == "loading" or page == "signin" then
		return 8
	end
	if page ~= "menu" then
		return 20
	end
	-- The dashboard: cards, tiles, the line below them and the recent work,
	-- with a row between each.
	local width, columns = M.dashboard_width()
	local cards = width >= 70 and 6 or 13
	local tiles = columns and 4 or 9
	local recent = #require("leetcode.ui.menu.recent").list(columns and 3 or 2)
	return cards + 1 + tiles + 1 + 1 + 1 + 2 + math.max(recent, 1)
end

local Home = m.component(function()
	M.dashboards = M.dashboards + 1

	return m.vflex({
		align = "center",
		margin_top = 1,
		function()
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
		m.block({ width = LAUNCHER, Nav({ width = LAUNCHER }) }),
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

	return m.block({
		-- The band runs along the top of the window, and the rest sits in the middle.
		-- Pinned, so scrolling a short window leaves it in place.
		m.block({
			position = "fixed",
			function()
				local _, columns = M.dashboard_width()
				return Band({ width = M.width(), compact = not columns })
			end,
		}),
		m.block({
			-- In the middle of what the band leaves, and again whenever the window
			-- changes size.
			margin_top = function()
				return math.max(math.floor((M.height() - BAND - content_height()) / 2), 1)
			end,
			m.show(gated, Gate, function()
				return m.vflex({
					align = "center",
					m.slide(function()
						return SLIDES[M.page()] or "home"
					end, function(key)
						if key == "home" then
							return Home()
						end
						local Page = key == "stats" and Stats or Problems
						return function()
							local width, columns = M.dashboard_width()
							return Page({ width = width, columns = columns })
						end
					end, {
						forward = function(_, to)
							return to ~= "home"
						end,
					}),
				})
			end),
		}),
	})
end)

function M.render()
	if not M.view then
		M.view = Markup.view(M.win, { snap = true, hide_cursor = true })
		M.view:on_commit(function()
			if not M.win:valid() then
				return
			end
			M.width(vim.api.nvim_win_get_width(M.win.win))
			M.height(vim.api.nvim_win_get_height(M.win.win))
			-- Something is always lit on the dashboard, from the moment it shows:
			-- the cursor goes to the nearest card until the user moves it.
			if M.home_page() == "menu" and not focus.current() then
				M.view.cursor = nil
				M.view:snap_cursor()
			end
		end)
	end
	M.width(vim.api.nvim_win_get_width(M.win.win))
	M.height(vim.api.nvim_win_get_height(M.win.win))
	M.view:render(App())
end

return M
