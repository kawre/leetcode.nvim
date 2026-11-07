---@module 'mini.test'

local helpers = dofile("tests/helpers.lua")
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_case = function()
			helpers.boot(child)
			child.lua([[
				errors = {}
				vim.notify = function(message, level)
					if level == vim.log.levels.ERROR then
						errors[#errors + 1] = message
					end
				end
			]])
		end,
		post_case = function()
			eq(child.lua_get("errors"), {})
		end,
		post_once = function()
			child.stop()
		end,
	},
})

local function run(code)
	child.lua(code)
end

local function description_has(text)
	return child.lua_get(("contains(problem.description.win.buf, %q)"):format(text))
end

local function header_has(text)
	return child.lua_get(("contains(problem.description.header.win.buf, %q)"):format(text))
end

--- Presses the first line holding `text` in the description.
local function press(text)
	run(([[
		vim.api.nvim_set_current_win(problem.description.win.win)
		for i, line in ipairs(buffer_text(problem.description.win.buf)) do
			local col = line:find(%q, 1, true)
			if col then
				vim.api.nvim_win_set_cursor(0, { i, col - 1 })
				break
			end
		end
	]]):format(text))
	child.type_keys("<CR>")
	run("reactive.flush()")
end

T["description"] = new_set()

T["description"]["pins the header in a band"] = function()
	run("open_problem()")
	eq(header_has("1. Two Sum"), true)
	eq(header_has("100"), true)
	eq(description_has("1. Two Sum"), false)
	eq(header_has("▄▄▄"), false)
	eq(header_has("▀▀▀"), false)
end

local function hint_has(text)
	return child.lua_get(("contains(problem.description.view.fixed[1].win.buf, %q)"):format(text))
end

local function scroll_description(top)
	run(([[
		local description = problem.description
		vim.api.nvim_win_call(description.win.win, function()
			vim.api.nvim_win_set_cursor(0, { %d, 0 })
			vim.cmd("normal! zt")
		end)
		description.view:update_scroll()
		reactive.flush()
		reactive.flush()
	]]):format(top))
end

T["description"]["says when text is hidden above"] = function()
	run("open_problem()")
	run([[vim.api.nvim_win_set_height(problem.description.win.win, 8)]])
	eq(child.lua_get("vim.api.nvim_win_get_config(problem.description.view.fixed[1].win.win).hide"), true)

	-- Rows: the header, then a blank one, and then the text.
	scroll_description(4)
	eq(hint_has(" 3+ "), true)
	eq(hint_has("───"), true)
	eq(child.lua_get("vim.api.nvim_win_get_config(problem.description.view.fixed[1].win.win).hide"), false)

	scroll_description(1)
	eq(child.lua_get("vim.api.nvim_win_get_config(problem.description.view.fixed[1].win.win).hide"), true)
end

T["description"]["blank rows alone do not count as hidden"] = function()
	run("open_problem()")
	scroll_description(2)
	eq(hint_has(" 1+ "), true)
end

T["description"]["the hint does not move the text"] = function()
	run([[
		open_problem()
		before = buffer_text(problem.description.win.buf)
	]])
	scroll_description(4)
	eq(child.lua_get("buffer_text(problem.description.win.buf)"), child.lua_get("before"))
end

T["description"]["the band has its own color"] = function()
	run([[
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "#222233" })
		require("leetcode.theme").load()
	]])
	eq(
		child.lua_get("vim.api.nvim_get_hl(0, { name = 'leetcode_description_header' }).bg"),
		child.lua_get("Markup.animate.mix(0x222233, 0xffffff, 0.06)")
	)
end

T["description"]["does not print the problem url"] = function()
	run("open_problem()")
	eq(header_has("leetcode.com"), false)
	eq(description_has("leetcode.com"), false)
end

T["description"]["gx opens the problem"] = function()
	run([[
		opened = nil
		vim.ui.open = function(url) opened = url end
		open_problem()
		vim.api.nvim_set_current_win(problem.description.win.win)
	]])
	child.type_keys("gx")
	eq(child.lua_get("opened"), "https://leetcode.com/problems/two-sum/")
end

T["description"]["links show a label and open on enter"] = function()
	run([[
		opened = nil
		vim.ui.open = function(url) opened = url end
		open_problem()
	]])
	eq(description_has("example.com"), false)
	eq(description_has("the docs"), true)

	press("the docs")
	eq(child.lua_get("opened"), "https://example.com/docs")
end

T["description"]["sections sit on their own background"] = function()
	run([[
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "#202020" })
		require("leetcode.theme").load()
		open_problem()
		desc = problem.description
		rows = {}
		for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(desc.win.buf, desc.view.ns, 0, -1, { details = true })) do
			if mark[4].hl_group == "leetcode_section" then
				rows[mark[2] + 1] = mark[4].end_col
			end
		end
		for i, line in ipairs(buffer_text(desc.win.buf)) do
			if line:find("nums = [2,7,11,15]", 1, true) then example_row = i end
			if line:find("Given an array", 1, true) then intro_row = i end
		end
	]])
	eq(child.lua_get("vim.api.nvim_get_hl(0, { name = 'leetcode_section' }).bg"), 0x101010)
	eq(child.lua_get("rows[example_row] ~= nil"), true)
	eq(child.lua_get("rows[intro_row] == nil"), true)
end

T["description"]["sections have half cell edges"] = function()
	run("open_problem()")
	eq(description_has("▄▄▄"), true)
	eq(description_has("▀▀▀"), true)
end

T["description"]["a collapsed section stays one tinted row"] = function()
	run("open_problem()")
	press("Example 1:")
	run([[
		desc = problem.description
		count = 0
		for _, line in ipairs(buffer_text(desc.win.buf)) do
			if line:find("Example 1:", 1, true) then
				row = _
			end
		end
		tinted = {}
		for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(desc.win.buf, desc.view.ns, { row - 1, 0 }, { row - 1, -1 }, { details = true })) do
			if mark[4].hl_group == "leetcode_section" then
				tinted[#tinted + 1] = mark[2] + 1
			end
		end
	]])
	eq(child.lua_get("tinted"), { child.lua_get("row") })
end

T["description"]["sections start open"] = function()
	run("open_problem()")
	eq(description_has("\u{eab4} Example 1:"), true)
	eq(description_has("nums = [2,7,11,15]"), true)
end

T["description"]["section headings have a single marker"] = function()
	run("open_problem()")
	eq(description_has("\u{eab4} Constraints:"), true)
	eq(description_has("▾"), false)
end

T["description"]["sections collapse and expand"] = function()
	run("open_problem()")

	press("Example 1:")
	eq(description_has("nums = [2,7,11,15]"), false)
	eq(description_has("Constraints:"), true)
	eq(description_has("\u{eab6} Example 1:"), true)

	press("Example 1:")
	eq(description_has("nums = [2,7,11,15]"), true)
end

T["description"]["sections are independent"] = function()
	run("open_problem()")

	press("Constraints:")
	eq(description_has("nums.length"), false)
	eq(description_has("nums = [2,7,11,15]"), true)
end

T["description"]["follow up is a section"] = function()
	run([[
		fixture.problem.content = fixture.problem.content
			.. "<p><strong>Follow-up: </strong>Can you do better than O(n^2)?</p>"
		open_problem()
	]])
	eq(description_has("Follow-up:"), true)
	eq(description_has("better than"), true)

	press("Follow-up:")
	eq(description_has("better than"), false)
end

T["description"]["wraps paragraphs inside the window"] = function()
	run("open_problem()")
	local width = child.lua_get("vim.api.nvim_win_get_width(problem.description.win.win)")
	for _, line in ipairs(child.lua_get("buffer_text(problem.description.win.buf)")) do
		eq(child.lua_get(("vim.fn.strdisplaywidth(%q)"):format(line)) <= width, true)
	end
end

T["description"]["renders links, sections and code"] = function()
	run("open_problem()")
	eq(description_has("the docs"), true)
	eq(description_has("Example 1:"), true)
	eq(description_has("nums = [2,7,11,15]"), true)
	eq(description_has("Constraints:"), true)
end

T["description"]["renders lists with markers"] = function()
	run("open_problem()")
	eq(description_has("* 2 <= nums.length <= 10^4"), true)
	eq(description_has("1. First"), true)
	eq(description_has("2. Second"), true)
end

T["header"] = new_set()

T["header"]["keeps numbers short"] = function()
	run([[description = require("leetcode.problem.description")]])
	eq(child.lua_get("description.compact(950)"), "950")
	eq(child.lua_get("description.compact(71085)"), "71.1K")
	eq(child.lua_get("description.compact(2000)"), "2K")
	eq(child.lua_get("description.compact(41400000)"), "41.4M")
	eq(child.lua_get("description.compact('10M')"), "10M")
end

T["header"]["shows where the problem stands"] = function()
	run("open_problem()")
	eq(header_has("Solved"), true)

	run([[
		problem:unmount()
		fixture.cached.status = "notac"
		open_problem()
	]])
	eq(header_has("Attempted"), true)
end

T["header"]["says nothing for untouched problems"] = function()
	run([[
		fixture.cached.status = "todo"
		open_problem()
	]])
	eq(header_has("Solved"), false)
	eq(header_has("Attempted"), false)
end

T["header"]["counts the hints"] = function()
	run([[
		fixture.problem.hints = { "a", "b", "c" }
		open_problem()
	]])
	eq(child.lua_get([[buffer_text(problem.description.header.win.buf)[3]:find(" 3", 1, true) ~= nil]]), true)
end

local function header_at(width)
	run(([[
		problem.description.header.view.width_cells(%d)
		reactive.flush()
		reactive.flush()
	]]):format(width))
end

T["header"]["details leave as the window narrows"] = function()
	run("open_problem()")
	eq(header_has("50% of 10M"), true)

	header_at(34)
	eq(header_has("50% of 10M"), false)
	eq(header_has("50%"), true)

	header_at(30)
	eq(header_has("50%"), false)
	eq(header_has("100"), true)

	header_at(14)
	eq(header_has("100"), false)
	eq(header_has("Easy"), true)
end

T["header"]["details come back when there is room"] = function()
	run("open_problem()")
	header_at(14)
	header_at(80)
	eq(header_has("50% of 10M"), true)
	eq(header_has("100"), true)
end

local function meter()
	return child.lua_get([[(function()
		local rows = buffer_text(problem.description.header.win.buf)
		return select(2, rows[1]:gsub("▔", ""))
	end)()]])
end

T["header"]["starts with a meter across the band"] = function()
	run("open_problem()")
	eq(meter(), child.lua_get("vim.api.nvim_win_get_width(problem.description.win.win)"))
end

T["header"]["the meter fills to the acceptance rate"] = function()
	run([[
		open_problem()
		band = problem.description.header
		marks = {}
		for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(band.win.buf, band.view.ns, 0, { 0, -1 }, { details = true })) do
			if mark[4].hl_group == "leetcode_easy" then
				filled = mark[4].end_col - mark[3]
			end
		end
	]])
	local width = child.lua_get("vim.api.nvim_win_get_width(problem.description.win.win)")
	-- Each cell of the meter is three bytes, and the fixture is at 50%.
	eq(child.lua_get("filled"), math.floor(width * 0.5 + 0.5) * 3)
end

T["header"]["the meter empties while stats are hidden"] = function()
	run([[
		open_problem()
		problem.description:toggle_stats()
		reactive.flush()
		band = problem.description.header
		filled = nil
		for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(band.win.buf, band.view.ns, 0, { 0, -1 }, { details = true })) do
			if mark[4].hl_group == "leetcode_easy" then filled = mark[4].end_col - mark[3] end
		end
	]])
	eq(child.lua_get("filled"), vim.NIL)
end

T["description"]["half cell edges are the only gap between sections"] = function()
	run([[
		open_problem()
		rows = buffer_text(problem.description.win.buf)
		for i, line in ipairs(rows) do
			if line:find("See", 1, true) then after_text = rows[i + 1] end
			if line:find("▀▀▀", 1, true) and not after_card then after_card = rows[i + 1] end
		end
	]])
	eq(child.lua_get("after_text"), "")
	eq(child.lua_get("after_card:find('▄', 1, true) ~= nil"), true)
end

T["cursor"] = new_set()

local function line()
	return child.lua_get("vim.trim(vim.api.nvim_get_current_line())")
end

local function enter_description()
	run([[
		open_problem()
		local description = problem.description
		description.win:focus()
		vim.api.nvim_win_set_cursor(0, { 1, 0 })
		description.view.cursor = nil
		description.view:snap_cursor()
	]])
end

T["cursor"]["starts on the first text"] = function()
	enter_description()
	eq(line():find("Given an array", 1, true), 1)
end

T["cursor"]["skips blank rows and card edges"] = function()
	enter_description()
	local seen = {}
	for _ = 1, 30 do
		seen[#seen + 1] = line()
		child.type_keys("j")
	end

	for _, row in ipairs(seen) do
		eq(row ~= "", true)
		eq(row:find("▄", 1, true), nil)
		eq(row:find("▀", 1, true), nil)
	end
	eq(vim.tbl_contains(seen, line()), true)
end

T["cursor"]["stays out of the padding"] = function()
	enter_description()
	child.type_keys("0")
	local start = child.lua_get("vim.fn.virtcol('.')")
	child.type_keys("h")
	eq(child.lua_get("vim.fn.virtcol('.')"), start)
	eq(start > 1, true)
end

T["cursor"]["reaches both ends of the page"] = function()
	enter_description()
	child.type_keys("G")
	eq(line():find("Similar Questions", 1, true) ~= nil, true)
	child.type_keys("gg")
	eq(line():find("Given an array", 1, true), 1)
end

T["images"] = new_set()

local function with_images(enabled)
	run(([[
		shown = {}
		local next_id = 0
		Markup.image.backend = {
			set = function(data_or_id, opts)
				if type(data_or_id) == "number" then shown[data_or_id] = opts; return data_or_id end
				next_id = next_id + 1
				shown[next_id] = opts
				return next_id
			end,
			del = function(id) shown[id] = nil; return true end,
		}
		Leet.config.user.image_support = %s

		local function u32(n)
			return string.char(math.floor(n / 16777216) %% 256, math.floor(n / 65536) %% 256, math.floor(n / 256) %% 256, n %% 256)
		end
		png = "\137PNG\r\n\26\n" .. u32(13) .. "IHDR" .. u32(180) .. u32(90) .. "rest"
		require("leetcode.image").load = function() return function() return png end end

		fixture.problem.content = [=[
<p>Look at this:</p>
<p><strong class="example">Example 1:</strong></p>
<img alt="" src="https://assets.leetcode.com/uploads/tree.jpg" style="width: 180px; height: 90px;" />
<pre><strong>Input:</strong> root = [1,2]</pre>
]=]
		open_problem()
		reactive.flush()
		reactive.flush()
	]]):format(enabled and "true" or "false"))
end

T["images"]["show in the description"] = function()
	with_images(true)
	eq(child.lua_get("vim.tbl_count(shown)"), 1)
	-- 180 pixels is 20 cells, and half as tall, in cells twice as tall as wide.
	eq(child.lua_get("({ next(shown) })[2].width"), 20)
	eq(child.lua_get("({ next(shown) })[2].height"), 5)
end

T["images"]["go with the section they are in"] = function()
	with_images(true)
	press("Example 1")
	run("reactive.flush()")
	eq(child.lua_get("vim.tbl_count(shown)"), 0)

	press("Example 1")
	run("reactive.flush()")
	eq(child.lua_get("vim.tbl_count(shown)"), 1)
end

T["images"]["stay links without support"] = function()
	with_images(false)
	eq(child.lua_get("vim.tbl_count(shown)"), 0)
	eq(description_has("tree.jpg"), true)
end

T["images"]["are downloaded once and kept"] = function()
	run([[
		local dir = vim.fn.tempname()
		vim.fn.mkdir(dir, "p")
		local file = dir .. "/picture.png"
		local function u32(n)
			return string.char(math.floor(n / 16777216) % 256, math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256)
		end
		bytes = "\137PNG\r\n\26\n" .. u32(13) .. "IHDR" .. u32(4) .. u32(2) .. "rest"
		local f = assert(io.open(file, "wb")); f:write(bytes); f:close()

		image = require("leetcode.image")
		url = "file://" .. file
		data = image.load(url)
		vim.wait(3000, function() return data() ~= nil end, 20)
		first = data()

		-- Gone from where it came from, so only the cache can give it back.
		os.remove(file)
		package.loaded["leetcode.image"] = nil
		again = require("leetcode.image").load(url)()
	]])
	eq(child.lua_get("first == bytes"), true)
	eq(child.lua_get("again == bytes"), true)
end

T["images"]["convert with what is installed"] = function()
	run([[image = require("leetcode.image")]])
	local command = child.lua_get("image.converter('in.jpg', 'out.png')")
	eq(type(command), "table")
	eq(vim.tbl_contains({ "magick", "convert", "ffmpeg" }, command[1]), true)
end

T["extras"] = new_set()

T["extras"]["follow the problem, all closed"] = function()
	run("open_problem()")
	eq(description_has("Hints"), true)
	eq(description_has("Topics"), true)
	eq(description_has("Similar Questions"), true)

	eq(description_has("1/1"), false)
	eq(description_has("* Array"), false)
	eq(description_has("3Sum"), false)

	run([[
		for i, line in ipairs(buffer_text(problem.description.win.buf)) do
			if line:find("Constraints", 1, true) then constraints = i end
			if line:find("Hints", 1, true) then hints = i end
		end
	]])
	eq(child.lua_get("hints > constraints"), true)
end

T["extras"]["open with enter"] = function()
	run("open_problem()")
	press("Topics")
	eq(description_has("* Array"), true)

	press("Similar Questions")
	eq(description_has("3Sum"), true)
end

T["extras"]["each hint opens on its own"] = function()
	run([[
		fixture.problem.hints = { "First <code>hint</code>.", "Second hint." }
		open_problem()
	]])
	press("Hints")
	eq(description_has("1/2"), true)
	eq(description_has("First hint."), false)

	press("1/2")
	eq(description_has("First hint."), true)
	eq(description_has("Second hint."), false)
end

T["extras"]["hints line up and end with the card"] = function()
	run([[
		fixture.problem.hints = { "First hint.", "Second hint." }
		open_problem()
	]])
	press("Hints")
	press("1/2")
	press("2/2")
	run([[
		local function column(line, text)
			local start = line:find(text, 1, true)
			return start and vim.fn.strdisplaywidth(line:sub(1, start - 1))
		end

		rows = buffer_text(problem.description.win.buf)
		for i, line in ipairs(rows) do
			title_col = title_col or column(line, "Hints")
			first_col = first_col or column(line, "First hint.")
			if line:find("First hint.", 1, true) then after_first = rows[i + 1] end
			if line:find("Second hint.", 1, true) then after_last = rows[i + 1] end
		end
	]])
	eq(child.lua_get("first_col"), child.lua_get("title_col"))
	-- A gap between hints, and the edge of the card right after the last one.
	eq(child.lua_get("after_first"), "")
	eq(child.lua_get("after_last:find('▀', 1, true) ~= nil"), true)
end

T["extras"]["empty sections do not show"] = function()
	run([[
		fixture.problem.hints, fixture.problem.similar = {}, {}
		open_problem()
	]])
	eq(description_has("Hints"), false)
	eq(description_has("Similar Questions"), false)
	eq(description_has("Topics"), true)
end

T["extras"]["similar problems open"] = function()
	run([[
		opened = nil
		Leet.cmd = { open = function(problem) opened = problem.title_slug end }
		open_problem()
	]])
	press("Similar Questions")
	press("3Sum")
	eq(child.lua_get("opened"), "3sum")
end

local function hover_similar()
	run([[
		open_problem()
	]])
	press("Similar Questions")
	run([[
		vim.api.nvim_set_current_win(problem.description.win.win)
		for i, line in ipairs(buffer_text(problem.description.win.buf)) do
			local col = line:find("3Sum", 1, true)
			if col then
				row = i
				vim.api.nvim_win_set_cursor(0, { i, col })
			end
		end
		vim.api.nvim_exec_autocmds("CursorMoved", { buffer = problem.description.win.buf })
		reactive.flush()
	]])
end

T["extras"]["similar problems say how to open them"] = function()
	hover_similar()
	eq(description_has("⏎ open"), true)

	run([[
		vim.api.nvim_win_set_cursor(0, { 1, 0 })
		vim.api.nvim_exec_autocmds("CursorMoved", { buffer = problem.description.win.buf })
		reactive.flush()
	]])
	eq(description_has("⏎ open"), false)
end

T["extras"]["the hint follows the confirm key"] = function()
	run([[Leet.config.user.keys.confirm = { "o", "<CR>" }]])
	hover_similar()
	eq(description_has("o open"), true)
end

T["extras"]["leet hints jumps to them"] = function()
	run([[
		open_problem()
		package.loaded["leetcode.util"].curr_question = function() return problem end
		vim.api.nvim_set_current_win(problem.win)
		require("leetcode.cmd").hints()
		reactive.flush()
		reactive.flush()
	]])
	eq(child.lua_get("vim.api.nvim_get_current_win() == problem.description.win.win"), true)
	eq(description_has("1/1"), true)
	eq(child.lua_get("vim.api.nvim_get_current_line():find('Hints', 1, true) ~= nil"), true)
end

T["extras"]["leet info opens the first section there is"] = function()
	run([[
		fixture.problem.hints = {}
		open_problem()
		package.loaded["leetcode.util"].curr_question = function() return problem end
		require("leetcode.cmd").info()
		reactive.flush()
		reactive.flush()
	]])
	eq(description_has("* Array"), true)
end

T["extras"]["leet hints shows a hidden description"] = function()
	run([[
		open_problem()
		package.loaded["leetcode.util"].curr_question = function() return problem end
		problem.description:toggle()
		require("leetcode.cmd").hints()
		reactive.flush()
		reactive.flush()
	]])
	eq(child.lua_get("problem.description.win:valid()"), true)
	eq(description_has("1/1"), true)
end

T["description"]["lists start at the margin of their section"] = function()
	run([[
		open_problem()
		local function column(line, text)
			local start = line:find(text, 1, true)
			return start and vim.fn.strdisplaywidth(line:sub(1, start - 1))
		end

		for _, line in ipairs(buffer_text(problem.description.win.buf)) do
			title_col = title_col or column(line, "Constraints")
			marker_col = marker_col or column(line, "* 2 <=")
			order_col = order_col or column(line, "1. First")
		end
	]])
	eq(child.lua_get("marker_col"), child.lua_get("title_col"))
	eq(child.lua_get("order_col"), child.lua_get("title_col"))
end

T["description"]["nested lists step in under their parent"] = function()
	run([[
		local html = require("leetcode.ui.problem.description.html")
		local win = Markup.window({ position = "float", width = 40, height = 10, enter = false })
		local view = Markup.view(win)
		view:render(m.block(html.parse("<ul><li>outer<ul><li>inner</li></ul></li></ul>")))
		reactive.flush()
		rows = buffer_text(win.buf)
	]])
	local rows = child.lua_get("rows")
	local outer, inner
	for _, row in ipairs(rows) do
		outer = outer or row:find("* outer", 1, true)
		inner = inner or row:find("* inner", 1, true)
	end
	eq(inner, outer + 2)
end

T["description"]["list items wrap with a hanging indent"] = function()
	run("open_problem()")
	run([[
		for i, line in ipairs(buffer_text(problem.description.win.buf)) do
			if line:find("Only one valid", 1, true) then
				marker_col = line:find("*", 1, true)
				next_line = buffer_text(problem.description.win.buf)[i + 1]
			end
		end
	]])
	local col = child.lua_get("marker_col")
	local next_line = child.lua_get("next_line")
	eq(next_line:sub(1, col + 1):match("^%s*$") ~= nil, true)
end

T["description"]["code wraps at the margin of the text"] = function()
	run([[
		fixture.problem.content = "<pre><strong>Input:</strong> " .. ("words "):rep(30) .. "</pre>"
		fixture.problem.hints, fixture.problem.topic_tags, fixture.problem.similar = {}, {}, {}
		open_problem()
		code = vim.tbl_filter(function(line)
			return line:find("%S") ~= nil
		end, buffer_text(problem.description.win.buf))
	]])
	local rows = child.lua_get("code")
	eq(#rows > 2, true)
	for _, row in ipairs(rows) do
		eq(row:match("^  %S") ~= nil, true)
		eq(row:find("│", 1, true), nil)
	end
end

T["description"]["renders tables with borders"] = function()
	run("open_problem()")
	eq(description_has("┌────┬──────┐"), true)
	eq(description_has("│ id │ name │"), true)
	eq(description_has("├────┼──────┤"), true)
	eq(description_has("│ 1  │ Joe  │"), true)
end

T["description"]["hides and shows stats"] = function()
	run("open_problem()")
	eq(header_has("????"), false)

	run("problem.description:toggle_stats(); reactive.flush()")
	eq(header_has("????"), true)
	eq(header_has("___"), true)
end

T["description"]["the header is a window above it"] = function()
	run("open_problem()")
	run([[
		header, body = problem.description.header.win.win, problem.description.win.win
		header_pos, body_pos = vim.fn.win_screenpos(header), vim.fn.win_screenpos(body)
	]])
	eq(child.lua_get("vim.api.nvim_win_get_config(header).relative"), "")
	eq(child.lua_get("header_pos[2] == body_pos[2]"), true)
	eq(child.lua_get("header_pos[1] < body_pos[1]"), true)
	-- The meter, the title and the stats. The row below the split is the padding.
	eq(child.lua_get("vim.api.nvim_win_get_height(header)"), 3)
end

T["description"]["no border between the header and the description"] = function()
	run([[
		open_problem()
		header = problem.description.header.win.win
		hl = vim.wo[header].winhighlight
		fill = vim.wo[header].fillchars
	]])
	eq(child.lua_get("hl:find('WinSeparator:leetcode_header_separator', 1, true) ~= nil"), true)
	eq(child.lua_get("hl:find('StatusLine:leetcode_description_header', 1, true) ~= nil"), true)
	eq(child.lua_get("fill:find('horiz: ', 1, true) ~= nil"), true)
end

T["description"]["moving between windows skips the header"] = function()
	run("open_problem()")
	child.type_keys("<C-w>k")
	child.lua("vim.wait(20, function() return false end, 5)")
	eq(child.lua_get("vim.api.nvim_get_current_win() == problem.description.win.win"), true)
end

T["description"]["the separator beside the header keeps its color"] = function()
	run([[
		open_problem()
		hl = vim.wo[problem.description.header.win.win].winhighlight
		separator = vim.api.nvim_get_hl(0, { name = "leetcode_header_separator", link = false })
		header = vim.api.nvim_get_hl(0, { name = "leetcode_description_header", link = false })
	]])
	eq(child.lua_get("hl:find('WinSeparator:leetcode_header_separator', 1, true) ~= nil"), true)
	eq(child.lua_get("separator.bg == header.bg"), true)
	eq(child.lua_get("separator.fg ~= nil"), true)
end

T["description"]["has the focus when a problem opens"] = function()
	run("open_problem()")
	eq(child.lua_get("vim.api.nvim_get_current_win() == problem.description.win.win"), true)
end

T["description"]["the header comes and goes with it"] = function()
	run([[
		open_problem()
		problem.description:toggle()
		reactive.flush()
	]])
	eq(child.lua_get("problem.description.header.win:win_valid() and true or false"), false)

	run([[
		problem.description:toggle()
		reactive.flush()
	]])
	eq(child.lua_get("problem.description.header.win:win_valid()"), true)
	eq(header_has("1. Two Sum"), true)
end

T["description"]["toggles its window"] = function()
	run([[
		open_problem()
		problem.description:toggle()
		reactive.flush()
	]])
	eq(child.lua_get("not problem.description.win:win_valid()"), true)

	run("problem.description:toggle(); reactive.flush()")
	eq(child.lua_get("problem.description.win:win_valid() and true"), true)
	eq(header_has("1. Two Sum"), true)
	eq(description_has("nums = [2,7,11,15]"), true)
end

T["console"] = new_set()

local function show_result(item)
	run(([[
		open_problem()
		problem.console:show("result")
		reactive.flush()
		item = %s
		problem.console.testcase:snapshot("run1", { test_case = "[2,7]\n9\n[3,3]\n6" })
		problem.console.result:handle(item)
		reactive.flush()
	]]):format(item))
end

local function result_has(text)
	return child.lua_get(("contains(problem.console.result.win.buf, %q)"):format(text))
end

local accepted = [[{
	_ = { title = "Accepted", hl = "leetcode_ok", success = true, submission = false },
	status_code = 10, status_runtime = "0 ms", submission_id = "run1", total_testcases = 2,
	code_answer = { "[0,1]", "[0,1]" }, expected_code_answer = { "[0,1]", "[0,1]" },
	std_output_list = { "hello\n", "" },
}]]

T["console"]["shows run results"] = function()
	show_result(accepted)
	eq(result_has("Accepted"), true)
	eq(result_has("Case"), true)
	eq(result_has("nums ="), true)
	eq(result_has("[2,7]"), true)
	eq(result_has("Expected"), true)
end

T["console"]["switches cases with number keys"] = function()
	show_result(accepted)
	eq(result_has("[3,3]"), false)

	run("vim.api.nvim_set_current_win(problem.console.result.win.win)")
	child.type_keys("2")
	run("reactive.flush()")
	eq(result_has("[3,3]"), true)
end

T["console"]["stdout collapses"] = function()
	show_result(accepted)
	eq(result_has("hello"), true)

	run([[
		vim.api.nvim_set_current_win(problem.console.result.win.win)
		for i, line in ipairs(buffer_text(problem.console.result.win.buf)) do
			if line:find("Stdout", 1, true) then
				vim.api.nvim_win_set_cursor(0, { i, #line:match("^%s*") })
			end
		end
		problem.console.result.view:press()
		reactive.flush()
	]])
	eq(result_has("hello"), false)
end

T["console"]["shows a submission"] = function()
	show_result([[{
		_ = { title = "Accepted", hl = "leetcode_ok", success = true, submission = true },
		status_code = 10, status_runtime = "12 ms", display_runtime = "12", pretty_lang = "Python3",
		status_memory = "18.9MB", runtime_percentile = 80.5, memory_percentile = 33.2,
	}]])
	eq(result_has("Runtime"), true)
	eq(result_has("Memory"), true)
	eq(result_has("18.9 MB"), true)
	eq(result_has("beats 80.5%"), true)
end

T["console"]["an accepted submission updates the problem and the stats"] = function()
	run([[
		refreshed = 0
		require("leetcode.ui.menu").refresh = function() refreshed = refreshed + 1 end
	]])
	show_result([[{
		_ = { title = "Accepted", hl = "leetcode_ok", success = true, submission = true },
		status_code = 10, status_runtime = "12 ms", display_runtime = "12", pretty_lang = "Python3",
		status_memory = "18.9MB", runtime_percentile = 80.5, memory_percentile = 33.2,
	}]])
	eq(child.lua_get("status_change"), { "two-sum", "ac" })
	eq(child.lua_get("refreshed"), 1)
end

T["console"]["a failed submission only updates the problem"] = function()
	run([[
		refreshed = 0
		require("leetcode.ui.menu").refresh = function() refreshed = refreshed + 1 end
	]])
	show_result([[{
		_ = { title = "Wrong Answer", hl = "leetcode_error", submission = true, params = {} },
		status_code = 11, input = "[1]", code_output = "[]", expected_output = "[1]", std_output = "",
	}]])
	eq(child.lua_get("status_change"), { "two-sum", "notac" })
	eq(child.lua_get("refreshed"), 0)
end

T["console"]["a plain run changes nothing"] = function()
	show_result(accepted)
	eq(child.lua_get("status_change"), vim.NIL)
end

T["console"]["shows a compile error"] = function()
	show_result([[{ _ = {}, status_code = 20, full_compile_error = "Line 1: bad\nLine 2: worse" }]])
	eq(result_has("Line 2: worse"), true)
end

T["console"]["shows a runtime error"] = function()
	show_result([[{
		_ = { title = "Runtime Error", hl = "leetcode_error", submission = false, params = {} },
		status_code = 15, full_runtime_error = "IndentationError\nLine 45", std_output_list = { "" },
	}]])
	eq(result_has("Runtime Error"), true)
	eq(result_has("Line 45"), true)
end

T["console"]["shows limits and internal errors"] = function()
	show_result([[{ _ = { submission = false }, status_code = 14, std_output_list = { "out" } }]])
	eq(result_has("out"), true)

	run([[problem.console.result:handle({ _ = {}, status_code = 16 }); reactive.flush()]])
	eq(result_has("The judge failed"), true)
end

T["console"]["shows a failed submission"] = function()
	show_result([[{
		_ = { title = "Wrong Answer", hl = "leetcode_error", submission = true, params = {} },
		status_code = 11, input = "[1]\n2", code_output = "[]", expected_output = "[1]", std_output = "",
	}]])
	eq(result_has("Expected"), true)
	eq(result_has("[1]"), true)
end

T["console"]["marks what differs from the expected output"] = function()
	show_result([[{
		_ = { title = "Wrong Answer", hl = "leetcode_error", submission = true, params = {} },
		status_code = 11, input = "[1]", code_output = "[0,2]", expected_output = "[0,1]", std_output = "",
		total_correct = 3, total_testcases = 4,
	}]])
	eq(result_has("3/4 passed"), true)
	eq(result_has("Wrong Answer"), true)

	local marked = function(group)
		return child.lua_get(([[(function()
			local result, buf = problem.console.result, problem.console.result.win.buf
			local found = {}
			for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, result.view.ns, 0, -1, { details = true })) do
				if mark[4].hl_group == %q then
					found[#found + 1] = vim.api.nvim_buf_get_text(buf, mark[2], mark[3], mark[4].end_row, mark[4].end_col, {})[1]
				end
			end
			return found
		end)()]]):format(group))
	end

	eq(marked("leetcode_diff_delete"), { "2" })
	eq(marked("leetcode_diff_add"), { "1" })
end

T["console"]["tabs show which cases passed"] = function()
	show_result([[{
		_ = { title = "Wrong Answer", hl = "leetcode_error", success = false, submission = false },
		status_code = 10, status_runtime = "1 ms", submission_id = "run1", total_testcases = 2,
		compare_result = "10", code_answer = { "[0,1]", "[0,2]" },
		expected_code_answer = { "[0,1]", "[0,1]" }, std_output_list = { "", "" },
	}]])
	run([[
		local rows = buffer_text(problem.console.result.win.buf)
		for _, line in ipairs(rows) do
			if line:find("Case 1", 1, true) then tabs = line end
		end
	]])
	eq(child.lua_get("tabs:find('Case 2', 1, true) ~= nil"), true)
end

T["console"]["shows the judge at work until the result"] = function()
	run([[
		open_problem()
		problem.console:show("result")
		problem.console.result:judging(true)
		reactive.flush()
	]])
	eq(result_has("Submitting your solution"), true)
	eq(result_has("Queued"), true)

	run([[
		problem.console.result:set_state("STARTED")
		reactive.flush()
		problem.console.result:handle({ _ = {}, status_code = 16 })
		reactive.flush()
	]])
	eq(result_has("Queued"), false)
end

T["console"]["celebrates accepted submissions only"] = function()
	run([[
		bursts = 0
		require("leetcode.ui.confetti").burst = function() bursts = bursts + 1 end
		require("leetcode.ui.menu").refresh = function() end
	]])
	show_result(accepted)
	eq(child.lua_get("bursts"), 0)

	run([[problem.console.result:handle({
		_ = { title = "Accepted", hl = "leetcode_ok", success = true, submission = true },
		status_code = 10, status_runtime = "12 ms", display_runtime = "12", pretty_lang = "Python3",
		status_memory = "18.9MB", runtime_percentile = 80.5, memory_percentile = 33.2,
	})]])
	eq(child.lua_get("bursts"), 1)

	run([[Leet.config.user.ui.confetti = false]])
	run([[problem.console.result:handle({
		_ = { title = "Accepted", hl = "leetcode_ok", success = true, submission = true },
		status_code = 10, status_runtime = "12 ms", display_runtime = "12", pretty_lang = "Python3",
		status_memory = "18.9MB", runtime_percentile = 80.5, memory_percentile = 33.2,
	})]])
	eq(child.lua_get("bursts"), 1)
end

T["console"]["clears"] = function()
	show_result(accepted)
	run("problem.console.result:clear(); reactive.flush()")
	eq(result_has("Accepted"), false)
end

T["console"]["toggles"] = function()
	run([[
		open_problem()
		problem.console:toggle()
		reactive.flush()
	]])
	eq(child.lua_get("problem.console:is_open()"), true)

	run("problem.console:toggle(); reactive.flush()")
	eq(child.lua_get("problem.console:is_open()"), false)
end

T["console"]["keeps results and testcases when reopened"] = function()
	show_result(accepted)
	run([[
		problem.console:toggle()
		reactive.flush()
		problem.console:toggle()
		reactive.flush()
	]])
	eq(result_has("Accepted"), true)
	run([[problem.console.tab("testcase"); reactive.flush()]])
	eq(result_has("[2,7]"), true)
end

T["console"]["keeps its keys when reopened"] = function()
	show_result(accepted)
	run([[
		problem.console:toggle()
		reactive.flush()
		problem.console:toggle()
		reactive.flush()
		vim.api.nvim_set_current_win(problem.console.result.win.win)
	]])
	child.type_keys("2")
	run("reactive.flush()")
	eq(result_has("[3,3]"), true)
end

local function open_console()
	run([[
		open_problem()
		problem.console:open()
		reactive.flush()
		vim.api.nvim_set_current_win(problem.console.win.win)
	]])
end

local function console_has(text)
	return child.lua_get(("contains(problem.console.win.buf, %q)"):format(text))
end

T["console"]["shows the judge's progress through a whole run"] = function()
	open_console()
	run([[
		local interpreter = require("leetcode.api.interpreter")
		local api = Leet.api
		seen = {}
		local function shown()
			reactive.flush()
			local text = table.concat(vim.api.nvim_buf_get_lines(problem.console.win.buf, 0, -1, false), "\n")
			return text
		end
		-- LeetCode takes the run, then reports it queued, then judging, then done.
		local checks = {
			{ state = "PENDING" },
			{ state = "STARTED" },
			{ status_code = 16, status_msg = "Internal Error" },
		}
		api.post = function(_, opts)
			opts.callback({ interpret_id = "run1", test_case = "[2,7]\n9" })
		end
		api.get = function(_, opts)
			local item = table.remove(checks, 1)
			if item.state then
				seen[#seen + 1] = item.state .. ": " .. tostring(shown():find(item.state == "PENDING" and "Queued" or "Judging", 1, true) ~= nil)
			end
			opts.callback(item)
			seen[#seen + 1] = (item.state or "done") .. " after: " .. (shown():find("Run your code", 1, true) and "placeholder" or "progress or result")
		end
		vim.defer_fn = function(fn) fn() end
		require("leetcode.problem.runner").running = false
		problem.console:run()
		vim.wait(200, function() return #checks == 0 end, 10)
		final = shown()
	]])
	for _, entry in ipairs(child.lua_get("seen")) do
		eq(entry:find("placeholder", 1, true), nil)
	end
	eq(child.lua_get("final"):find("The judge failed", 1, true) ~= nil, true)
	-- The next check runs inside the last one here, so the order is nested.
	local seen = child.lua_get("seen")
	eq(#seen, 5)
	eq(vim.tbl_contains(seen, "PENDING: true"), true)
	eq(vim.tbl_contains(seen, "STARTED: true"), true)
end

T["console"]["is one split below the editor"] = function()
	open_console()
	run([[
		local editor, console = problem.win, problem.console.win.win
		editor_pos, console_pos = vim.fn.win_screenpos(editor), vim.fn.win_screenpos(console)
		floating = vim.api.nvim_win_get_config(console).relative ~= ""
		same_width = vim.api.nvim_win_get_width(editor) == vim.api.nvim_win_get_width(console)
		below = console_pos[1] > editor_pos[1] and console_pos[2] == editor_pos[2]
	]])
	eq(child.lua_get("floating"), false)
	eq(child.lua_get("same_width"), true)
	eq(child.lua_get("below"), true)
end

T["console"]["switches between testcases and results"] = function()
	open_console()
	eq(console_has("Testcase"), true)
	eq(console_has("Result"), true)
	eq(console_has("nums ="), true)

	child.type_keys("<Tab>")
	run("reactive.flush()")
	eq(child.lua_get("problem.console.tab()"), "result")
	eq(console_has("nums ="), false)
	eq(console_has("Run your code"), true)

	child.type_keys("<S-Tab>")
	run("reactive.flush()")
	eq(child.lua_get("problem.console.tab()"), "testcase")
end

T["console"]["running shows the results"] = function()
	open_console()
	run([[
		require("leetcode.problem.runner").run = function() ran = true end
		problem.console:run()
		reactive.flush()
	]])
	eq(child.lua_get("ran"), true)
	eq(child.lua_get("problem.console.tab()"), "result")
end

T["console"]["shows each parameter of a case"] = function()
	open_console()
	eq(console_has("Case 1"), true)
	eq(console_has("Case 2"), true)
	eq(console_has("target ="), true)
	eq(console_has("[2,7]"), true)
	eq(console_has("[3,3]"), false)

	child.type_keys("2")
	run("reactive.flush()")
	eq(console_has("[3,3]"), true)
	eq(console_has("[2,7]"), false)
end

T["console"]["adds, removes and resets cases"] = function()
	open_console()
	child.type_keys("2", "a")
	run("reactive.flush()")
	eq(console_has("Case 3"), true)
	eq(child.lua_get("problem.console.testcase.selected()"), 3)
	-- A new case starts from the one shown.
	eq(child.lua_get("problem.console.testcase.cases()[3]"), { "[3,3]", "6" })

	child.type_keys("d", "d", "d", "d")
	run("reactive.flush()")
	-- One always stays.
	eq(child.lua_get("#problem.console.testcase.cases()"), 1)

	child.type_keys("r")
	run("reactive.flush()")
	eq(child.lua_get("#problem.console.testcase.cases()"), 2)
end

T["console"]["enter on a field types over it, and on a case picks it"] = function()
	open_console()
	run([[
		local function row_of(text)
			for i, line in ipairs(vim.api.nvim_buf_get_lines(problem.console.win.buf, 0, -1, false)) do
				if line:find(text, 1, true) then return i end
			end
		end
		vim.api.nvim_win_set_cursor(0, { row_of("[2,7]"), 6 })
		vim.cmd("doautocmd CursorMoved")
		reactive.flush()
	]])
	child.type_keys("<CR>")
	run("reactive.flush()")
	eq(child.lua_get("problem.console.typing()"), 1)
	eq(child.lua_get("vim.api.nvim_win_get_config(0).relative"), "win")

	child.type_keys("<Esc>")
	run([[
		reactive.flush()
		local line = vim.api.nvim_buf_get_lines(problem.console.win.buf, 0, -1, false)
		for i, text in ipairs(line) do
			local col = text:find("Case 2", 1, true)
			if col then vim.api.nvim_win_set_cursor(0, { i, col }) end
		end
		vim.cmd("doautocmd CursorMoved")
		reactive.flush()
	]])
	child.type_keys("<CR>")
	run("reactive.flush()")
	eq(child.lua_get("problem.console.testcase.selected()"), 2)
end

T["console"]["types a value over its field"] = function()
	open_console()
	run([[
		problem.console.testcase:edit(2)
		reactive.flush()
		input = vim.api.nvim_get_current_win()
		floating = vim.api.nvim_win_get_config(input).relative == "win"
		-- Over the field, on the row of its value.
		local row = vim.api.nvim_win_get_config(input).row
		over = vim.api.nvim_buf_get_lines(problem.console.win.buf, row, row + 1, false)[1]
		typing = problem.console.typing()
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "42" })
		vim.cmd("doautocmd TextChanged")
		vim.cmd("stopinsert")
	]])
	eq(child.lua_get("floating"), true)
	eq(child.lua_get("over"):find("9", 1, true) ~= nil, true)
	eq(child.lua_get("typing"), 2)

	child.type_keys("<Esc>")
	run("reactive.flush()")
	eq(child.lua_get("vim.api.nvim_win_is_valid(input)"), false)
	eq(child.lua_get("vim.api.nvim_get_current_win() == problem.console.win.win"), true)
	eq(console_has("42"), true)
	eq(child.lua_get("problem.console.testcase:content()"), "[2,7]\n42\n[3,3]\n6")
end

T["dev"] = new_set()

local function fetch(content, translated)
	run(([[
		dev = require("leetcode.dev")
		dev.problems_dir = vim.fn.tempname()
		Leet.api.query = function()
			return { data = { question = {
				frontend_id = "1", title_slug = "two-sum", content = %s, translated_content = %s,
				meta_data = "{}", stats = "{}",
			} } }
		end
		fetched = require("leetcode.api.problems").by_slug("two-sum")
	]]):format(content, translated))
end

local function saved(name)
	return child.lua_get(("vim.fn.filereadable(dev.problems_dir .. %q) == 1 and table.concat(vim.fn.readfile(dev.problems_dir .. %q), '\\n') or nil"):format(name, name))
end

T["dev"]["is off by default"] = function()
	fetch([["<p>x</p>"]], "vim.NIL")
	eq(saved("/1.two-sum.html"), vim.NIL)
end

T["dev"]["saves the raw html of fetched problems"] = function()
	run([[require("leetcode.config").user.dev = true]])
	fetch([["<p>raw &amp; html</p>"]], "vim.NIL")
	eq(saved("/1.two-sum.html"), "<p>raw &amp; html</p>")
	eq(saved("/1.two-sum.cn.html"), vim.NIL)
end

T["dev"]["saves translations separately"] = function()
	run([[require("leetcode.config").user.dev = true]])
	fetch([["<p>en</p>"]], [["<p>cn</p>"]])
	eq(saved("/1.two-sum.cn.html"), "<p>cn</p>")
end

T["dev"]["a failed save does not stop the fetch"] = function()
	run([[
		require("leetcode.config").user.dev = true
		warned = nil
		require("leetcode.logger").warn = function(message) warned = message end
		dev = require("leetcode.dev")
		dev.problems_dir = "/proc/nope/nope"
		Leet.api.query = function()
			return { data = { question = {
				frontend_id = "1", title_slug = "two-sum", content = "x", meta_data = "{}", stats = "{}",
			} } }
		end
		fetched = require("leetcode.api.problems").by_slug("two-sum")
	]])
	eq(child.lua_get("fetched ~= nil"), true)
	eq(child.lua_get("warned ~= nil"), true)
end

T["dev"]["the folder is ignored by git"] = function()
	local result = vim.fn.system({ "git", "check-ignore", ".dev/problems/1.two-sum.html" })
	eq(vim.trim(result), ".dev/problems/1.two-sum.html")
end

--- Real pages saved by dev mode. Each one opened adds coverage, and without any
--- this simply has nothing to check.
T["real problems"] = function()
	local failures = child.lua_get([[(function()
		local failures = {}
		local description_width = 60

		for _, path in ipairs(vim.fn.glob(".dev/problems/*.html", true, true)) do
			local name = vim.fn.fnamemodify(path, ":t")
			local content = table.concat(vim.fn.readfile(path), "\n")

			local ok, err = xpcall(function()
				local html = require("leetcode.ui.problem.description.html")
				local win = Markup.window({
					position = "float", width = description_width, height = 20, enter = false,
				})
				local view = Markup.view(win)
				view:render(m.block({ padding = { 1, 2 }, html.parse(content) }))
				reactive.flush()

				local lines = vim.api.nvim_buf_get_lines(win.buf, 0, -1, false)
				local tinted = {}
				for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(win.buf, view.ns, 0, -1, { details = true })) do
					if mark[4].hl_group == "leetcode_section" then
						local before = lines[mark[2] + 1]:sub(1, mark[4].end_col)
						tinted[#tinted + 1] = vim.fn.strdisplaywidth(before)
					end
				end

				for i = 2, #tinted do
					if tinted[i] ~= tinted[1] then
						table.insert(failures, ("%s: card rows end at %d and %d"):format(name, tinted[1], tinted[i]))
						break
					end
				end

				for i, line in ipairs(lines) do
					assert(not line:find("\t", 1, true), "tab in line " .. i)
					local has_box = line:find("[┌├└]") or line:find("│ ", 1, true)
					local width = vim.fn.strdisplaywidth(line)
					if width > description_width and not has_box then
						table.insert(failures, ("%s: line %d is %d wide"):format(name, i, width))
					end
				end

				view:destroy()
				win:close()
			end, debug.traceback)

			if not ok then
				table.insert(failures, name .. ": " .. tostring(err):sub(1, 200))
			end
		end

		return failures
	end)()]])
	eq(failures, {})
end

T["problem"] = new_set()

T["problem"]["opens the editor with the snippet"] = function()
	run("open_problem()")
	eq(child.lua_get("problem:valid()"), true)
	eq(child.lua_get("contains(problem.buf, 'class Solution')"), true)
end

T["problem"]["is found from its tab"] = function()
	run("open_problem()")
	eq(child.lua_get("Leet.util.curr_question() == problem"), true)
end

T["problem"]["unmounts"] = function()
	run([[
		open_problem()
		problem:unmount()
		reactive.flush()
	]])
	eq(child.lua_get("#Leet.active_problems"), 0)
	eq(child.lua_get("problem:valid()"), false)
end

return T
