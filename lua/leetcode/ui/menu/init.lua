local m = require("markup")
local i18n = require("leetcode.i18n")
local cookie = require("leetcode.cache.cookie")
local kit = require("leetcode.ui.kit")
local Nav = require("leetcode.ui.menu.nav")
local Band = require("leetcode.ui.menu.dashboard.band")
local focus = require("leetcode.ui.menu.dashboard.focus")
local Header = require("leetcode.ui.menu.dashboard.header")
local Drop = require("leetcode.ui.menu.dashboard.drop")
local data = require("leetcode.ui.menu.data")
local Stats = require("leetcode.ui.menu.stats")
local Problems = require("leetcode.ui.menu.problems")

--- Pages that are not part of the navigation, but take the dashboard's place.
local SLIDES = { ["menu.statistics"] = "stats", ["menu.problems"] = "problems" }

--- Pages before there is a user, which do not drop.
local SLIDES_GATED = { loading = true, signin = true }

---@class leet.menu
local M = {
	page = m.signal("loading"),
	--- The page of the navigation, which stays put while statistics are open.
	home_page = m.signal("loading"),
	stats_version = m.signal(0),
	width = m.signal(vim.o.columns),
	height = m.signal(vim.o.lines),
	--- The presses of the page shown, for the header to list.
	actions = m.signal({}),
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

--- Lists the presses of a page in the header while it shows. The page binds
--- their keys itself.
---@param actions leet.ui.menu.header.action[]
function M.use_actions(actions)
	M.actions(actions)
	m.on_cleanup(function()
		-- A new page sets its own as the old one is still on its way out.
		if m.untrack(M.actions) == actions then
			M.actions({})
		end
	end)
end

--- Whether a page is still on its way out, while the cursor waits for it.
M.dropping = false

--- Where the cursor waits while pages drop and rise: the first row, under the
--- band, which nothing moves past. Snapping is off meanwhile, or it would pull
--- the cursor onto the page falling, and follow it down.
local parked ---@type { win: integer, option: string, value: string }?

local function park()
	if parked or not M.win:valid() then
		return
	end
	local win = M.win.win
	-- Neovim 0.11 has no per-window list, so the global one stands in.
	local local_option = vim.fn.exists("+eventignorewin") == 1
	local option = local_option and "eventignorewin" or "eventignore"
	local value = local_option and vim.wo[win][option] or vim.o[option]
	local ignored = value == "" and "CursorMoved" or value .. ",CursorMoved"
	if local_option then
		vim.wo[win][option] = ignored
	else
		vim.o[option] = ignored
	end
	parked = { win = win, option = option, value = value }

	vim.api.nvim_win_set_cursor(win, { 1, 0 })
	if M.view then
		M.view.cursor = nil
	end
	-- Never longer than a transition could take, whatever happens to it.
	vim.defer_fn(M.unpark, 1500)
end

--- Lets the cursor go, onto the nearest thing on the page that came in.
function M.unpark()
	M.dropping = false
	if not parked then
		return
	end
	local was = parked
	parked = nil
	if was.option == "eventignorewin" then
		if vim.api.nvim_win_is_valid(was.win) then
			vim.wo[was.win][was.option] = was.value
		end
	else
		vim.o[was.option] = was.value
	end

	M.dropping = false
	if M.view and M.win:valid() and vim.api.nvim_get_current_win() == M.win.win then
		M.view.cursor = nil
		M.view:snap_cursor()
		M.view:update_hover()
	end
end

---@param page string
function M.set_page(page)
	-- What was lit belongs to the page being left, and the cursor waits for it
	-- to be gone before it lands on the new one.
	focus.current(nil)
	if M.page() ~= page and not SLIDES_GATED[M.page()] then
		M.dropping = true
		park()
	end
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

--- Rows of the band pinned along the top.
local BAND = 3
--- Rows of the header above the page: its line, its rule and one row below.
local HEADER = 3

--- About how tall the dashboard is. Every page is placed as the dashboard
--- would be, so the header above them stays where it is from page to page.
---@return integer
local function dashboard_height()
	local width, columns = M.dashboard_width()
	local cards = width >= 70 and 6 or 13
	local tiles = columns and 4 or 9
	local recent = #require("leetcode.ui.menu.recent").list(columns and 3 or 2)
	-- Cards, tiles, the line below them and the recent work, a row between each.
	return cards + 1 + tiles + 1 + 1 + 1 + 2 + math.max(recent, 1)
end

--- Rows above the header, to put the dashboard and its header in the middle.
---@return integer
local function top_margin()
	return math.max(math.floor((M.height() - BAND - HEADER - dashboard_height()) / 2), 1)
end

--- A page of the navigation, the dashboard or the account, by its key: a page
--- falling away keeps showing what it was, whatever the menu moved on to.
---@param props { page: string }
local Home = m.component(function(props)
	if props.page == "menu" then
		M.dashboards = M.dashboards + 1
	end

	return function()
		local width, columns = M.dashboard_width()
		return m.block({
			width = width,
			Nav({ width = width, columns = columns, page = props.page }),
		})
	end
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
	-- Closing the menu mid-transition still lets the cursor go.
	m.on_cleanup(M.unpark)

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

	--- The page for a key, below the header.
	local function page_of(key)
		if key == "menu.statistics" or key == "menu.problems" then
			local Page = key == "menu.statistics" and Stats or Problems
			return m.vflex({
				align = "center",
				function()
					local width, columns = M.dashboard_width()
					return Page({ width = width, columns = columns })
				end,
			})
		end
		return m.vflex({ align = "center", Home({ page = key }) })
	end

	return m.block({
		-- The band runs along the top of the window, pinned, so it stays as the
		-- page below changes or scrolls.
		m.block({
			position = "fixed",
			function()
				local _, columns = M.dashboard_width()
				return Band({ width = M.width(), compact = not columns })
			end,
		}),
		m.show(gated, function()
			return m.block({
				margin_top = function()
					return math.max(math.floor((M.height() - BAND - 8) / 2), 1)
				end,
				Gate(),
			})
		end, function()
			-- The header sits just above the page, and stays while pages drop
			-- away and rise below it.
			return m.block({
				margin_top = top_margin,
				Header({
					width = function()
						return (M.dashboard_width())
					end,
				}),
				Drop({
					key = M.page,
					render = page_of,
					-- Down to the bottom of the window, and no further.
					depth = function()
						return math.max(M.height() - BAND - top_margin() - HEADER, 1)
					end,
					on_arrived = M.unpark,
				}),
			})
		end),
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
			if not M.dropping and not focus.current() then
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
