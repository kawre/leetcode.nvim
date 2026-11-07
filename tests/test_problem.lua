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
	return child.lua_get(("contains(problem.description.view.fixed[1].win.buf, %q)"):format(text))
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
	return child.lua_get(("contains(problem.description.view.fixed[2].win.buf, %q)"):format(text))
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
	eq(child.lua_get("vim.api.nvim_win_get_config(problem.description.view.fixed[2].win.win).hide"), true)

	-- Rows: the header, then a blank one, and then the text.
	scroll_description(4)
	eq(hint_has(" 3+ "), true)
	eq(hint_has("───"), true)
	eq(child.lua_get("vim.api.nvim_win_get_config(problem.description.view.fixed[2].win.win).hide"), false)

	scroll_description(1)
	eq(child.lua_get("vim.api.nvim_win_get_config(problem.description.view.fixed[2].win.win).hide"), true)
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
	eq(child.lua_get([[buffer_text(problem.description.view.fixed[1].win.buf)[3]:find(" 3", 1, true) ~= nil]]), true)
end

local function header_at(width)
	run(([[
		problem.description.view.width_cells(%d)
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
		local rows = buffer_text(problem.description.view.fixed[1].win.buf)
		return select(2, rows[#rows]:gsub("▂", ""))
	end)()]])
end

T["header"]["ends in a meter across the band"] = function()
	run("open_problem()")
	eq(meter(), child.lua_get("vim.api.nvim_win_get_width(problem.description.win.win)"))
end

T["header"]["the meter fills to the acceptance rate"] = function()
	run([[
		open_problem()
		band = problem.description.view.fixed[1]
		marks = {}
		local rows = vim.api.nvim_buf_line_count(band.win.buf)
		for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(band.win.buf, band.view.ns, { rows - 1, 0 }, -1, { details = true })) do
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
		band = problem.description.view.fixed[1]
		filled = nil
		local rows = vim.api.nvim_buf_line_count(band.win.buf)
		for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(band.win.buf, band.view.ns, { rows - 1, 0 }, -1, { details = true })) do
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
		problem.console:open()
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
		problem.console:open()
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
	eq(child.lua_get("contains(problem.console.testcase.win.buf, '[2,7]')"), true)
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

T["popups"] = new_set()

T["popups"]["skills"] = function()
	run([[
		skills = require("leetcode.ui.popup.skills")
		skills:show()
		reactive.flush()
	]])
	eq(child.lua_get("contains(skills.win.buf, 'advanced')"), true)
	eq(child.lua_get("contains(skills.win.buf, 'Dynamic Programming x5')"), true)
end

T["popups"]["languages sort by solved"] = function()
	run([[
		languages = require("leetcode.ui.popup.languages")
		languages:show()
		reactive.flush()
		first = buffer_text(languages.win.buf)[2]
	]])
	eq(child.lua_get("first"):find("Python", 1, true) ~= nil, true)
	eq(child.lua_get("contains(languages.win.buf, '12 problems solved')"), true)
	eq(child.lua_get("contains(languages.win.buf, '1 problem solved')"), true)
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
