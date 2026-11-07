local m = require("markup")
local config = require("leetcode.config")
local html = require("leetcode.ui.problem.description.html")
local extras = require("leetcode.ui.problem.description.extras")
local kit = require("leetcode.ui.kit")
local t = require("leetcode.translator")

local img_ok, image_api = pcall(require, "image")
local img_sup = img_ok and config.user.image_support

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
	self.images = {}
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
	})

	self.view = Markup.view(self.win)
	self:bind_keys()
	self.view:render(self:content())
	self:draw_images()

	if config.user.image_support and not img_ok then
		Markup.log.error("image.nvim not found but `image_support` is enabled")
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

function M:header()
	local q, cached = self.problem.problem, self.problem.cached

	local function stats()
		local visible = self.stats_visible()
		local spans = {}

		local function add(text, hl)
			spans[#spans + 1] = m.inline(text, hl)
		end

		local separator = (" %s "):format(config.icons.bar)

		if visible then
			spans[#spans + 1] = kit.Pill(t(q.difficulty), q.difficulty)
		else
			add("????", "leetcode_list")
		end

		local status = config.icons.hl.status[cached.status]
		if status then
			add(" ")
			add(status[1], status[2])
		end

		add(separator)
		add((visible and q.likes or "___") .. " ", "leetcode_alt")
		if not config.is_cn then
			add((" %s "):format(visible and q.dislikes or "___"), "leetcode_alt")
		end

		add(separator)
		local ac_rate = visible and q.stats.acRate or "__%"
		local total = visible and q.stats.totalSubmission or "__"
		add(("%s %s %s"):format(ac_rate, t("of"), total), "leetcode_alt")

		if not vim.tbl_isempty(q.hints) then
			add(separator)
			add("󰛨 " .. t("Hints"), "leetcode_hint")
		end

		return m.block(spans)
	end

	return m.vflex({
		position = "fixed",
		top = 0,
		style = "leetcode_description_header",
		padding = { 1, 2 },
		m.flex({
			justify = "between",
			m.block({
				shrink = 1,
				m.inline(q.frontend_id .. ". ", "leetcode_alt"),
				m.inline(Leet.util.translate(q.title, q.translated_title), "Title"),
				q.is_paid_only and m.inline(" " .. t("Premium"), "leetcode_medium"),
			}),
			m.inline({ " " .. html.LINK_ICON, style = "leetcode_link", shrink = 0 }),
		}),
		stats,
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

	local header = self.view.fixed[1] and self.view.fixed[1].height or 0
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
				local rule = vim.api.nvim_win_get_width(self.win.win) - vim.api.nvim_strwidth(label) - 2
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
		self:header(),
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

function M:draw_images()
	if not img_sup then
		return
	end

	vim.schedule(function()
		if not self.win:valid() then
			return
		end

		local lines = vim.api.nvim_buf_get_lines(self.win.buf, 0, -1, false)
		for i, line in ipairs(lines) do
			for link in line:gmatch("%((http[s]?://%S+)%)") do
				if not self.images[link] then
					self.images[link] = {}
					image_api.from_url(link, {
						buffer = self.win.buf,
						window = self.win.win,
						with_virtual_padding = true,
					}, function(image)
						if image then
							self.images[link] = image
							image:render({ y = i + 1 })
						end
					end)
				end
			end
		end
	end)
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
	self.view:destroy()
	self.win:close()
end

return M
