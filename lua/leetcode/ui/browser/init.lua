--- Browses every problem from the menu, in a column beside it. Filters stay
--- pinned in their own window, so they remain real buttons while the list scrolls.
---
--- The list is a `Markup.picker`, drawn into these windows: it moves, scrolls
--- and searches as every picker does, counts and the mouse wheel included,
--- with the filters, the rows and the search field of the browser's own.

local i18n = require("leetcode.i18n")
local m = require("markup")
local reactive = require("markup.reactive")
local kit = require("leetcode.ui.kit")
local filter = require("leetcode.ui.browser.filter")
local ui = require("leetcode.ui.util")

local animate = Markup.animate
local api = vim.api

local FILTERS_HEIGHT = 9
local WIDTH = 0.5

---@class leet.ui.browser
---@field layout? markup.layout
local M = {}

local difficulties = {
	{
		value = "all",
		title = function()
			return i18n.difficulty("All")
		end,
	},
	{
		value = "easy",
		title = function()
			return i18n.difficulty("Easy")
		end,
		lhs = "e",
		kind = "easy",
	},
	{
		value = "medium",
		title = function()
			return i18n.difficulty("Medium")
		end,
		lhs = "m",
		kind = "medium",
	},
	{
		value = "hard",
		title = function()
			return i18n.difficulty("Hard")
		end,
		lhs = "H",
		kind = "hard",
	},
}

local statuses = {
	{
		value = "all",
		title = function()
			return i18n.any
		end,
	},
	{
		value = "ac",
		title = function()
			return i18n.status("ac")
		end,
		lhs = "s",
	},
	{
		value = "notac",
		title = function()
			return i18n.status("notac")
		end,
		lhs = "x",
	},
	{
		value = "todo",
		title = function()
			return i18n.todo
		end,
		lhs = "o",
	},
}

--- A filter that can be pressed, showing its key.
local Choice = m.component(function(props)
	local hovered = m.signal(false)

	return m.inline({
		click = "double",
		on_press = props.press,
		on_hover = hovered,
		white_space = "nowrap",
		style = function()
			if props.active() then
				return "leetcode_tab_active"
			end
			return hovered() and "leetcode_row_active" or "leetcode_tab"
		end,
		m.inline((" %s "):format(type(props.title) == "function" and props.title() or props.title)),
		props.lhs and m.inline({
			style = function()
				return props.active() and "leetcode_tab_active" or "leetcode_key"
			end,
			props.lhs .. " ",
		}),
	})
end)

local function choices(options, selected, set)
	return m.flex({
		spacing = 1,
		vim.tbl_map(function(option)
			return Choice({
				title = option.title,
				lhs = option.lhs,
				active = function()
					return selected() == option.value
				end,
				press = function()
					set(option.value)
				end,
			})
		end, options),
	})
end

--- Room the count takes at the end of the search field.
---@param state table
---@return integer
local function count_width(state)
	local total = #state.problems
	return vim.api.nvim_strwidth(tostring(total) .. i18n.of_total(total))
end

--- An input across the top, which the search float covers while typing. It is
--- lighter while selected, and lighter still with a bar of the accent beside it
--- while typing.
local SearchField = m.component(function(props)
	local state = props.state
	local hovered = m.signal(false)

	local light = m.animated(0, { duration = 120 })
	local bar = m.animated(0, { duration = 120 })
	m.effect(function()
		local typing = state.typing()
		light(typing and 1 or hovered() and 0.5 or 0)
		bar(typing and 1 or 0)
	end)

	local field = kit.color("leetcode_input", "bg")
	local focused = kit.color("leetcode_input_focus", "bg")
	local fill = animate.tint({ bg = field }, { bg = focused }, light)
	-- A half block inside the fill, which at rest has the color of the fill.
	local edge = animate.tint({ fg = field }, { fg = kit.color("leetcode_accent", "fg") }, bar)
	state.field_style = fill

	return m.flex({
		click = "double",
		on_press = state.search,
		on_hover = hovered,
		white_space = "nowrap",
		margin_bottom = 1,
		style = fill,
		m.block({
			width = 1,
			shrink = 0,
			m.block("▌", edge),
			m.block("▌", edge),
			m.block("▌", edge),
		}),
		m.flex({
			grow = 1,
			justify = "between",
			padding = { 1, 1 },
			m.inline({
				shrink = 1,
				m.inline(kit.icons.search .. " ", "leetcode_accent"),
				m.inline({
					style = function()
						return state.query() == "" and "leetcode_muted" or "leetcode_strong"
					end,
					function()
						local query = state.query()
						return query == "" and i18n.search_problems or query
					end,
				}),
			}),
			m.inline({
				shrink = 0,
				margin_left = 2,
				m.inline(function()
					-- The count matters once anything narrows the list, the hint before.
					local everything = #state.filtered() == #state.problems
					if everything and state.query() == "" and not state.typing() then
						return m.inline({
							m.inline("i ", "leetcode_key"),
							m.inline(i18n.to_search, "leetcode_muted"),
						})
					end
					return m.inline({
						m.inline(tostring(#state.filtered()), "leetcode_strong"),
						m.inline(i18n.of_total(#state.problems), "leetcode_muted"),
					})
				end),
			}),
		}),
	})
end)

local Filters = m.component(function(props)
	local state = props.state

	return m.block({
		padding = { 1, 2 },
		SearchField({ state = state }),
		m.block({ margin_bottom = 1, choices(difficulties, state.difficulty, state.difficulty) }),
		m.flex({
			spacing = 1,
			choices(statuses, state.status, state.status),
			Choice({
				title = i18n.free,
				lhs = "f",
				active = state.free,
				press = state.toggle_free,
			}),
		}),
	})
end)

--- A row of the list. Rows show only while they fit, so what one is doing, such
--- as opening its problem, is kept in the state rather than in the row.
---@param state table
local function Row(state, problem, ctx)
	local config = require("leetcode.config")
	local status = config.icons.hl.status[problem.status]
	local locked = problem.paid_only and not config.auth.is_premium
	local marker = locked and config.icons.lock or (status and status[1] or " ")
	local number = (" %5s  "):format(problem.frontend_id)
	local rate = ("  %5.1f%%  "):format(problem.ac_rate or 0)
	return m.flex({
		style = ctx.selected and "leetcode_row_active" or nil,
		justify = "between",
		white_space = "nowrap",
		m.inline({
			shrink = 1,
			overflow_x = "hidden",
			text_overflow = "󰇘",
			m.inline(ctx.selected and "▌" or " ", "leetcode_accent"),
			m.inline(function()
				if state.busy()[problem.title_slug] then
					return kit.Loader("leetcode_accent")
				end
				return m.inline(marker, locked and "leetcode_medium" or status and status[2])
			end),
			m.inline(number, "leetcode_muted"),
			m.inline(function()
				local title = Leet.util.translate(problem.title, problem.title_cn)
				return vim.tbl_map(function(span)
					return m.inline(span[1], span[2])
				end, filter.highlight(title, state.query()))
			end),
		}),
		m.inline({
			shrink = 0,
			margin_right = 1,
			m.inline(rate, "leetcode_muted"),
			-- Six cells, which a difficulty in Chinese takes fewer bytes than.
			m.inline({
				width = 6,
				m.inline(i18n.difficulty(problem.difficulty), ui.diff_to_hl(problem.difficulty)),
			}),
		}),
	})
end

---@param problems leet.cache.problem[]
local function create_state(problems)
	local state = {
		problems = problems,
		difficulty = m.signal("all"),
		status = m.signal("all"),
		free = m.signal(false),
		typing = m.signal(false),
		-- The problems being opened, by slug, each with its loader in its row.
		busy = m.signal({}),
	}

	function state.toggle_free()
		state.free(not state.free())
	end

	--- Matches for the query and every filter, as the picker wants them.
	function state.match(items, query)
		return vim.tbl_map(
			function(problem)
				return { item = problem }
			end,
			filter.apply(items, {
				difficulty = state.difficulty(),
				status = state.status(),
				free = state.free(),
				query = query,
			})
		)
	end

	return state
end

--- Types into a line over the search field, filtering on every key.
---@param state table
local function search(state)
	local anchor = M.filters
	if not (anchor and anchor:valid()) or state.typing() then
		return
	end

	local buf = api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	api.nvim_buf_set_lines(buf, 0, -1, false, { state.query() })

	local win = api.nvim_open_win(buf, true, {
		relative = "win",
		win = anchor.win,
		-- Over the text of the field: past the padding of the window, the bar and
		-- the padding of the field, and the icon.
		row = 2,
		col = 6,
		width = math.max(api.nvim_win_get_width(anchor.win) - 6 - 3 - 2 - count_width(state), 10),
		height = 1,
		style = "minimal",
		zindex = 60,
	})
	vim.wo[win].winhighlight = "NormalFloat:" .. (state.field_style or "leetcode_input_focus")
	state.typing(true)
	state.search_win = win
	M.picker:attach_input(buf, win)
	vim.cmd.startinsert({ bang = true })
end

--- Ends typing, however it ends, and goes back to the list.
---@param state table
local function leave_search(state)
	if not state.typing() then
		return
	end
	state.typing(false)
	M.picker:detach_input()
	local win = state.search_win
	state.search_win = nil
	if win and api.nvim_win_is_valid(win) then
		api.nvim_win_close(win, true)
	end
	M.picker:focus_list()
end

--- Goes to the filters on purpose, which moving between windows does not.
function M.focus_filters()
	if M.filters and M.filters:valid() then
		M.entering_filters = true
		M.filters:focus()
	end
end

function M.is_open()
	return M.layout ~= nil and M.layout:valid()
end

---@param problems leet.cache.problem[]
function M.open(problems)
	if M.is_open() then
		return M.list:focus()
	end

	local state = create_state(problems)

	--- Opens a problem, with a loader in its row until it does.
	---@param problem leet.cache.problem
	---@param from_row? boolean false for one that was not picked from a row
	state.open = function(problem, from_row)
		local slug = problem.title_slug
		if state.busy()[slug] then
			return
		end

		local task
		if from_row == false then
			-- Nothing on screen started it, so the corner shows it, and closing
			-- the browser meanwhile means it is not wanted.
			local close = require("leetcode.ui.toast")(
				require("leetcode.i18n").opening(
					Leet.util.translate(problem.title, problem.title_cn)
				)
			)
			local browser = M.list
			task = {
				cancelled = function()
					local gone = M.list ~= browser or not M.is_open()
					if gone then
						close()
					end
					return gone
				end,
				done = close,
			}
		else
			local picker = M.picker
			local function set(busy)
				local all = vim.deepcopy(state.busy())
				all[slug] = busy or nil
				state.busy(all)
			end
			set(true)
			task = {
				-- A browser closed meanwhile wants nothing opened.
				cancelled = function()
					return M.picker ~= picker or picker.closed
				end,
				done = function()
					if not picker.closed then
						set(false)
					end
				end,
			}
		end
		require("leetcode.cmd").open(problem, task)
	end

	M.picker = Markup.picker.new({
		items = problems,
		filter = state.match,
		click = "double",
		-- It stays while a problem opens, and beside the menu.
		close_on_select = false,
		auto_close = false,
		esc = "normal",
		render = {
			row = function(entry, ctx)
				return Row(state, entry.item, ctx)
			end,
			empty = function()
				return m.block({ padding = { 2, 3 }, m.inline(i18n.no_matches, "leetcode_muted") })
			end,
		},
		on_select = function(problem)
			leave_search(state)
			state.open(problem)
		end,
		-- q, <Esc> and the like close the picker, and the browser with it.
		on_close = function()
			M.close()
		end,
		-- Typing happens in a float over the search field, there only while typing.
		on_focus_input = function()
			search(state)
		end,
		on_input_leave = function()
			leave_search(state)
		end,
		keys = {},
	})
	state.query = M.picker.query
	state.filtered = M.picker.filtered
	state.search = function()
		M.picker:focus_input()
	end

	local options = { show = false, minimal = true, wo = { winhighlight = "Normal:Normal" } }
	M.filters = Markup.window(vim.tbl_extend("force", options, {}))
	M.list = Markup.window(vim.tbl_extend("force", options, {}))

	M.layout = Markup.layout({
		wins = { filters = M.filters, list = M.list },
		show = false,
		layout = {
			box = "vertical",
			focusable = true,
			position = "right",
			width = WIDTH,
			{ win = "filters", height = FILTERS_HEIGHT },
			{ win = "list" },
		},
	})
	M.layout:show()

	-- Moving between windows lands on the list. The windows float over a split
	-- of the layout, which is what moving into the column reaches, and the
	-- filters are reached on purpose, with Tab.
	local function to_list(win)
		vim.schedule(function()
			if M.list and M.list:valid() and api.nvim_get_current_win() == win then
				M.picker:focus_list()
			end
		end)
	end

	M.layout.root:on("WinEnter", function()
		to_list(M.layout.root.win)
	end, { buf = true })

	M.filters:on("WinEnter", function()
		if M.entering_filters then
			M.entering_filters = false
			return
		end
		to_list(M.filters.win)
	end, { buf = true })

	-- The marked row shows where the selection is.
	M.filters_view = Markup.view(M.filters, { snap = true, hide_cursor = true })

	local keys = {
		f = state.toggle_free,
		["<Tab>"] = function()
			if api.nvim_get_current_win() == M.list.win then
				M.focus_filters()
			else
				M.picker:focus_list()
			end
		end,
		r = function()
			local filtered = M.picker.filtered()
			if #filtered > 0 then
				state.open(filtered[math.random(#filtered)].item, false)
			end
		end,
	}

	-- A filter key turns its filter off again, which is how to get back to all.
	local function toggles(options, signal)
		for _, option in ipairs(options) do
			if option.lhs then
				keys[option.lhs] = function()
					signal(signal() == option.value and "all" or option.value)
				end
			end
		end
	end
	toggles(difficulties, state.difficulty)
	toggles(statuses, state.status)
	for lhs, action in pairs(keys) do
		M.picker.opts.keys[lhs] = function()
			action()
			reactive.flush()
		end
	end

	M.picker:own(M.layout.root.win)
	M.picker:own(M.filters.win)
	M.picker:bind(M.filters.buf, "other")
	M.filters:map("n", "<CR>", function()
		M.filters_view:press()
	end)
	M.picker:attach_list(M.list)
	M.list_view = M.picker.view

	M.filters_view:render(Filters({ state = state }))
	M.picker:focus_list()
end

function M.close()
	if not M.is_open() or M.closing then
		return
	end
	M.closing = true

	-- Closing the picker comes back here, which then has nothing to do.
	local picker = M.picker
	if picker and not picker.closed then
		picker:close()
	end
	M.filters_view:destroy()
	M.filters:close()
	M.list:close()
	M.layout:close({ wins = false })
	M.layout = nil
	M.closing = false
end

return M
