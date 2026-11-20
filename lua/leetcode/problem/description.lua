local m = require("markup")
local config = require("leetcode.config")
local html = require("leetcode.ui.problem.description.html")
local extras = require("leetcode.ui.problem.description.extras")
local kit = require("leetcode.ui.kit")
local t = require("leetcode.translator")

---@class leet.problem.description
---@field problem leet.problem
---@field win markup.window
---@field view markup.view
---@overload fun(problem: leet.problem): leet.problem.description
local M = Markup.object()

--- `"40%"` to `0.4`, which is what windows expect.
local function size(value)
	if type(value) == "string" then
		return (tonumber((value:gsub("%%", ""))) or 40) / 100
	end
	return value
end

---@param problem leet.problem
function M:new(problem)
	local opts = config.user.description

	self.problem = problem
	self.stats_visible = m.signal(opts.show_stats)

	self.win = Markup.window({
		win = problem.win,
		relative = "win",
		position = opts.position,
		width = size(opts.width),
		enter = false,
		focusable = true,
		minimal = true,
		bo = { filetype = config.name },
		wo = { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" },
		on_close = function()
			self:hide_header()
		end,
	})

	self.view = Markup.view(self.win, { snap = "text" })
	self:bind_keys()
	self:mount_header()
	self.view:render(self:content())

	-- Reading the problem comes before writing the solution.
	if self.win:valid() then
		self.win:focus()
	end
	if config.user.image_support and not Markup.image.available() then
		Markup.log.warn(
			"`image_support` needs a Neovim with `vim.ui.img`, or image.nvim, links are shown instead"
		)
	end
end

--- The header is a window of its own above the description, as tall as what it
--- shows. It opens and closes with the description.
function M:mount_header()
	local win = Markup.window({
		relative = "win",
		win = self.win.win,
		position = "top",
		height = 1,
		enter = false,
		show = false,
		minimal = true,
		bo = { filetype = config.name },
		-- The row Neovim keeps below a split, a separator or a status line, takes
		-- the color of the header and nothing else, so it reads as its padding.
		wo = {
			winhighlight = table.concat({
				"Normal:leetcode_description_header",
				"WinSeparator:leetcode_header_separator",
				"StatusLine:leetcode_description_header",
				"StatusLineNC:leetcode_description_header",
			}, ","),
			fillchars = "horiz: ,horizup: ,horizdown: ,eob: ",
			statusline = " ",
			winfixheight = true,
		},
	})

	local view = Markup.view(win)
	self.header = { win = win, view = view }

	view:on_commit(function()
		if win:win_valid() then
			local root = require("markup.view.protocol").ROOT
			local height = view.engine:describe(root).outer_height or 1
			vim.api.nvim_win_set_height(win.win, math.max(height, 1))
		end
	end)

	self.win:on_show(function()
		self:show_header()
	end)

	-- There is nothing to do in it, so moving into it lands on the description.
	-- Neovim moves between splits whether they are focusable or not.
	win:on("WinEnter", function()
		vim.schedule(function()
			if self.win:win_valid() and vim.api.nvim_get_current_win() == win.win then
				self.win:focus()
			end
		end)
	end, { buf = true })

	self:show_header()
	view:render(self:header_content())
end

function M:show_header()
	local header = self.header
	if header and self.win:win_valid() and not header.win:win_valid() then
		header.win.opts.win = self.win.win
		header.win:show()
	end
end

function M:hide_header()
	if self.header and self.header.win:win_valid() then
		self.header.win:close()
	end
end

function M:bind_keys()
	for _, lhs in ipairs(vim.iter({ config.user.keys.confirm }):flatten():totable()) do
		self.win:map("n", lhs, function()
			self.view:press()
		end)
	end

	self.win:map("n", "gx", function()
		self:open_link()
	end)
end

--- Opens the problem, since the fixed header cannot be pressed.
function M:open_link()
	local link = self.problem.cached.link
	if link then
		vim.ui.open(link)
	end
end

--- A count that stays short, such as `71.1K`.
---@param count any
---@return string
function M.compact(count)
	local number = tonumber(count)
	if not number then
		return tostring(count)
	end

	for _, unit in ipairs({ { 1e6, "M" }, { 1e3, "K" } }) do
		if number >= unit[1] then
			return ("%.1f"):format(number / unit[1]):gsub("%.0$", "") .. unit[2]
		end
	end
	return tostring(number)
end

--- Where the problem stands for the user, if anywhere.
function M:status()
	local status = config.icons.hl.status[self.problem.cached.status]
	if not status then
		return
	end

	local label = self.problem.cached.status == "ac" and "Solved" or "Attempted"
	return m.inline({
		white_space = "nowrap",
		m.inline(status[1] .. " " .. t(label), status[2]),
	})
end

--- The difficulty and how the problem was received. Details leave as the window
--- narrows, least important first, so that nothing runs into anything else.
function M:stats()
	local q = self.problem.problem
	local visible = self.stats_visible()
	local width = vim.api.nvim_strwidth
	local available = self.header.view:columns() - 4

	local difficulty = visible and t(q.difficulty) or "????"
	local used = width(difficulty) + 2

	local function stat(icon, value, hl)
		local text = (" %s"):format(visible and M.compact(value) or "___")
		local item = {
			width = 2 + width(icon) + width(text),
			element = m.inline({
				margin_left = 2,
				m.inline(icon, "leetcode_muted"),
				m.inline(text, hl or "leetcode_alt"),
			}),
		}
		used = used + item.width
		return item
	end

	local likes = stat(kit.icons.thumb_up, q.likes)
	local dislikes = not config.is_cn and stat(kit.icons.thumb_down, q.dislikes)
	local hint_count = #(q.hints or {})
	local hints = hint_count > 0 and stat(kit.icons.bulb, hint_count, "leetcode_hint")

	local rate = visible and q.stats.acRate or "__%"
	local total = visible and q.stats.totalSubmission or "__"
	local right = ("%s %s %s"):format(rate, t("of"), total)

	if used + 2 + width(right) > available then
		right = rate
	end
	if used + 2 + width(right) > available then
		right = nil
	end

	for _, item in ipairs({ dislikes or {}, hints or {}, likes }) do
		if used > available and item.element then
			used = used - item.width
			item.element = nil
		end
	end

	return m.flex({
		justify = "between",
		white_space = "nowrap",
		m.inline({
			visible and kit.Pill(difficulty, q.difficulty) or m.inline(difficulty, "leetcode_list"),
			likes.element,
			dislikes and dislikes.element,
			hints and hints.element,
		}),
		right and m.inline(right, "leetcode_alt"),
	})
end

--- How many submissions pass, along the top edge of the band. It takes the place
--- of the padding, so it adds no height.
function M:meter()
	local q = self.problem.problem
	local rate = (tonumber((tostring(q.stats.acRate):gsub("%%", ""))) or 0) / 100
	local filled = m.animated(0, { duration = 800, delay = 170 })

	m.effect(function()
		filled(self.stats_visible() and rate or 0)
	end)

	local function cells()
		return math.floor(filled() * self.header.view:columns() + 0.5)
	end

	return m.block({
		white_space = "nowrap",
		m.inline(function()
			return ("▔"):rep(cells())
		end, "leetcode_" .. q.difficulty:lower()),
		m.inline(function()
			return ("▔"):rep(self.header.view:columns() - cells())
		end, "leetcode_header_track"),
	})
end

function M:header_content()
	local q = self.problem.problem

	return m.vflex({
		style = "leetcode_description_header",
		self:meter(),
		m.vflex({
			-- No padding below: the row below the split is the padding.
			padding = { 0, 2 },
			m.flex({
				justify = "between",
				m.block({
					shrink = 1,
					m.inline(q.frontend_id .. ". ", "leetcode_muted"),
					m.inline(Leet.util.translate(q.title, q.translated_title), "leetcode_strong"),
					q.is_paid_only and m.inline(" " .. t("Premium"), "leetcode_medium"),
				}),
				m.inline({
					shrink = 0,
					margin_left = 2,
					self:status(),
					m.inline("  " .. html.LINK_ICON, "leetcode_muted"),
				}),
			}),
			function()
				return self:stats()
			end,
		}),
	})
end

--- Lines of text out of sight above the header. The row of the indicator counts,
--- since it covers a line too, and rows without text do not.
---@return integer
function M:hidden_lines()
	local top = self.view:scroll()
	if top == 0 or not self.win:valid() then
		return 0
	end

	local header = 0
	local lines = vim.api.nvim_buf_get_lines(self.win.buf, header, top + header + 1, false)

	local count = 0
	for _, line in ipairs(lines) do
		if line:gsub("[▄▀]", ""):find("%S") then
			count = count + 1
		end
	end
	return count
end

--- Tells that there is more above, under the header.
function M:scroll_hint()
	local hidden = m.memo(function()
		return self:hidden_lines()
	end)

	return m.block({
		position = "fixed",
		overlay = true,
		m.show(function()
			return hidden() > 0
		end, function()
			return function()
				local label = (" %s %d+ "):format(kit.icons.arrow_up, hidden())
				-- The pill has a cap on each side.
				local rule = self.view:columns() - vim.api.nvim_strwidth(label) - 2
				local left = math.floor(rule / 2)

				return m.block({
					white_space = "nowrap",
					m.inline(("─"):rep(left), "leetcode_rule"),
					kit.Pill(label, "accent"),
					m.inline(("─"):rep(rule - left), "leetcode_rule"),
				})
			end
		end),
	})
end

function M:content()
	local q = self.problem.problem
	local sections
	sections, self.sections = extras.build(q)

	return m.block({
		self:scroll_hint(),
		m.vflex({
			padding = { 1, 2 },
			spacing = 1,
			m.block({
				html.parse(Leet.util.translate(q.content, q.translated_content)),
				sections,
			}),
		}),
	})
end

--- Opens a section and brings it into view. Without a name that is the first one.
---@param name? "hints"|"topics"|"similar"
function M:reveal(name)
	local section = self.sections[name]
	if not name then
		for _, candidate in ipairs(extras.sections) do
			section = section or self.sections[candidate.name]
		end
	end

	if not section then
		return Markup.log.warn(t("No hints available"))
	end

	self:show()
	self.win:focus()
	section.open(true)

	self.view:after_commit(function()
		local lines = vim.api.nvim_buf_get_lines(self.win.buf, 0, -1, false)
		-- The text of the problem may use the same word, so look from the end.
		for row = #lines, 1, -1 do
			local col = lines[row]:find(section.title, 1, true)
			if col then
				vim.api.nvim_win_set_cursor(self.win.win, { row, col - 1 })
				vim.cmd("normal! zz")
				return
			end
		end
	end)
end

function M:show()
	if not self.win:valid() then
		self.win:show()
	end
end

function M:toggle()
	self.win:toggle()
end

function M:toggle_stats()
	self.stats_visible(function(visible)
		return not visible
	end)
end

function M:unmount()
	self.header.view:destroy()
	self:hide_header()
	self.view:destroy()
	self.win:close()
end

return M
