--- Browses every problem from the menu, in a column beside it. Filters stay
--- pinned in their own window, so they remain real buttons while the list scrolls.

local i18n = require("leetcode.i18n")
local m = require("markup")
local reactive = require("markup.reactive")
local kit = require("leetcode.ui.kit")
local filter = require("leetcode.ui.browser.filter")
local ui = require("leetcode.ui.util")

local animate = Markup.animate
local api = vim.api

--- Rows mounted at a time. Scrolling near the end brings in the next batch.
local BATCH = 200
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

local Row = m.component(function(props)
	local problem, state = props.problem, props.state
	local hovered = m.signal(false)
	local config = require("leetcode.config")

	local status = config.icons.hl.status[problem.status]
	local locked = problem.paid_only and not config.auth.is_premium
	-- While the question is fetched. A row filtered away meanwhile opens nothing.
	local busy, start = kit.use_task()

	return m.flex({
		click = "double",
		on_press = function()
			start(function(task)
				state.open(problem, task)
			end)
		end,
		on_hover = function(value)
			hovered(value)
			if value then
				state.reached(props.index)
			end
		end,
		style = function()
			return hovered() and "leetcode_row_active" or nil
		end,
		justify = "between",
		white_space = "nowrap",
		m.inline({
			shrink = 1,
			m.inline(function()
				return hovered() and "▌" or " "
			end, "leetcode_accent"),
			m.inline(function()
				if busy() then
					return m.loader({ style = "leetcode_accent" })
				end
				return m.inline(
					locked and config.icons.lock or (status and status[1] or " "),
					locked and "leetcode_medium" or status and status[2]
				)
			end),
			m.inline((" %5s  "):format(problem.frontend_id), "leetcode_muted"),
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
			m.inline(("  %5.1f%%  "):format(problem.ac_rate or 0), "leetcode_muted"),
			-- Six cells, which a difficulty in Chinese takes fewer bytes than.
			m.inline({
				width = 6,
				m.inline(i18n.difficulty(problem.difficulty), ui.diff_to_hl(problem.difficulty)),
			}),
		}),
	})
end)

local List = m.component(function(props)
	local state = props.state

	return m.block({
		m.each(state.visible, function(problem, index)
			return Row({ problem = problem, index = index, state = state })
		end, {
			key = function(problem)
				return problem.title_slug
			end,
		}),
		m.show(function()
			return #state.filtered() == 0
		end, function()
			return m.block({ padding = { 2, 3 }, m.inline(i18n.no_matches, "leetcode_muted") })
		end),
	})
end)

---@param problems leet.cache.problem[]
local function create_state(problems)
	local state = {
		problems = problems,
		difficulty = m.signal("all"),
		status = m.signal("all"),
		free = m.signal(false),
		query = m.signal(""),
		typing = m.signal(false),
		limit = m.signal(BATCH),
	}

	state.filtered = m.memo(function()
		return filter.apply(problems, {
			difficulty = state.difficulty(),
			status = state.status(),
			free = state.free(),
			query = state.query(),
		})
	end)

	state.visible = m.memo(function()
		local filtered = state.filtered()
		local limit = state.limit()
		return #filtered > limit and vim.list_slice(filtered, 1, limit) or filtered
	end)

	function state.toggle_free()
		state.free(not state.free())
	end

	--- Brings in more rows once the cursor nears the end.
	function state.reached(index)
		if index > state.limit() - 30 and state.limit() < #state.filtered() then
			state.limit(state.limit() + BATCH)
		end
	end

	return state
end

--- Types into a line over the search field, filtering on every key.
---@param state table
local function search(state)
	local anchor = M.filters
	if not (anchor and anchor:valid()) then
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

	--- Neovim holds back TextChangedI while keys are queued, so whatever acts on
	--- the query reads it first.
	local function sync()
		local text = api.nvim_buf_is_valid(buf) and api.nvim_buf_get_lines(buf, 0, 1, false)[1]
			or ""
		if text ~= state.query() then
			state.query(text)
			M.list_view:after_commit(M.to_top)
			reactive.flush()
		end
	end

	api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
		buffer = buf,
		callback = sync,
	})

	local function leave()
		vim.cmd.stopinsert()
		state.typing(false)
		if api.nvim_win_is_valid(win) then
			api.nvim_win_close(win, true)
		end
		M.list:focus()
	end

	local function move(by)
		sync()
		M.select_row(api.nvim_win_get_cursor(M.list.win)[1] + by)
	end

	local keys = {
		["<Esc>"] = leave,
		["<CR>"] = function()
			sync()
			leave()
			M.list_view:press()
		end,
	}
	for _, lhs in ipairs({ "<C-n>", "<Down>", "<C-j>" }) do
		keys[lhs] = function()
			move(1)
		end
	end
	for _, lhs in ipairs({ "<C-p>", "<Up>", "<C-k>" }) do
		keys[lhs] = function()
			move(-1)
		end
	end
	for lhs, action in pairs(keys) do
		vim.keymap.set({ "i", "n" }, lhs, action, { buffer = buf, nowait = true })
	end

	vim.cmd.startinsert({ bang = true })
end

--- Puts the cursor of the list on a row, and marks it, from any window.
---@param row integer
function M.select_row(row)
	if not (M.list and M.list:valid()) then
		return
	end

	api.nvim_win_call(M.list.win, function()
		local last = api.nvim_buf_line_count(M.list.buf)
		api.nvim_win_set_cursor(0, { math.max(math.min(row, last), 1), 0 })
		M.list_view.cursor = nil
		M.list_view:snap_cursor()
		M.list_view:update_hover()
	end)
end

--- Puts the cursor back on the first row, which filtering may have replaced.
function M.to_top()
	M.select_row(1)
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
	state.search = function()
		search(state)
	end

	---@param task? leet.ui.task from the row pressed
	state.open = function(problem, task)
		if not task then
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
		end
		require("leetcode.cmd").open(problem, task)
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
				M.list:focus()
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

	-- The marked row shows where the cursor is, so it only shows while typing.
	M.filters_view = Markup.view(M.filters, { snap = true, hide_cursor = true })
	M.list_view = Markup.view(M.list, { snap = true, hide_cursor = true })

	local function set_filter(signal, value)
		signal(value)
		state.limit(BATCH)
		M.list_view:after_commit(M.to_top)
	end

	local keys = {
		f = state.toggle_free,
		q = M.close,
		["<Tab>"] = function()
			if api.nvim_get_current_win() == M.list.win then
				M.focus_filters()
			else
				M.list:focus()
			end
		end,
		r = function()
			local filtered = state.filtered()
			if #filtered > 0 then
				state.open(filtered[math.random(#filtered)])
			end
		end,
	}
	-- Like the keys that start insert mode anywhere else, these start typing.
	for _, lhs in ipairs({ "/", "i", "a", "I", "A" }) do
		keys[lhs] = state.search
	end

	-- A filter key turns its filter off again, which is how to get back to all.
	local function toggles(options, signal)
		for _, option in ipairs(options) do
			if option.lhs then
				keys[option.lhs] = function()
					set_filter(signal, signal() == option.value and "all" or option.value)
				end
			end
		end
	end
	toggles(difficulties, state.difficulty)
	toggles(statuses, state.status)

	for _, win in ipairs({ M.filters, M.list }) do
		for lhs, action in pairs(keys) do
			win:map("n", lhs, action, { nowait = true })
		end
	end
	M.filters:map("n", "<CR>", function()
		M.filters_view:press()
	end)
	M.list:map("n", "<CR>", function()
		M.list_view:press()
	end)

	M.filters_view:render(Filters({ state = state }))
	M.list_view:render(List({ state = state }))
	M.list:focus()
end

function M.close()
	if not M.is_open() then
		return
	end

	M.filters_view:destroy()
	M.list_view:destroy()
	M.filters:close()
	M.list:close()
	M.layout:close({ wins = false })
	M.layout = nil
end

return M
