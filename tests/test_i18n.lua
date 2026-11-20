---@module 'mini.test'

--- The UI in each language: that every language gives every name, that the
--- code only reads names that exist, and that the UI shows them and keeps its
--- shape with the wider text of Chinese.

local helpers = dofile("tests/helpers.lua")
local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_case = function()
			helpers.boot(child)
		end,
		post_once = function()
			child.stop()
		end,
	},
})

local function run(code)
	child.lua(code)
end

local function chinese()
	run([[require("leetcode.config").translator = true]])
end

--- A value for each argument a function of the text takes, by its name.
local SAMPLES = {
	greeting = { "morning", "tester" },
	accepted_rate = { 52.5 },
	ago = { 3, "d" },
	skill = { "fundamental" },
	month = { 10 },
	difficulty = { "Easy" },
	status = { "ac" },
	of_total = { 3000 },
	acceptance = { "52.1%", "2.3M" },
	case = { 2 },
	passed = { 3, 4 },
	lines = { 2 },
	more_lines = { 1 },
	invalid_case = { 2 },
	edit_case = { 2 },
	opening = { "Two Sum" },
}

T["names"] = new_set()

T["names"]["every language gives every name, as the same kind"] = function()
	local mismatched = child.lua([[
		local en, zh = require("leetcode.i18n.en"), require("leetcode.i18n.zh")
		local wrong = {}
		for name, value in pairs(en) do
			if type(zh[name]) ~= type(value) then
				wrong[#wrong + 1] = ("%s: %s in en, %s in zh"):format(name, type(value), type(zh[name]))
			end
		end
		for name in pairs(zh) do
			if en[name] == nil then
				wrong[#wrong + 1] = name .. ": only in zh"
			end
		end
		table.sort(wrong)
		return wrong
	]])
	eq(mismatched, {})
end

T["names"]["each function gives text in both languages"] = function()
	local broken = child.lua(
		[[
		local samples = ...
		local broken = {}
		for _, locale in ipairs({ "en", "zh" }) do
			for name, value in pairs(require("leetcode.i18n." .. locale)) do
				if type(value) == "function" then
					local args = samples[name]
					local ok, text = pcall(value, unpack(args or {}))
					if not args then
						broken[#broken + 1] = locale .. "." .. name .. ": no sample arguments in the test"
					elseif not ok or type(text) ~= "string" or text == "" then
						broken[#broken + 1] = locale .. "." .. name .. ": " .. tostring(text)
					end
				end
			end
		end
		table.sort(broken)
		return broken
	]],
		{ SAMPLES }
	)
	eq(broken, {})
end

T["names"]["the code reads only names that exist"] = function()
	local missing = child.lua([[
		local en = require("leetcode.i18n.en")
		local missing, seen = {}, {}
		local files = vim.fn.globpath("lua", "**/*.lua", false, true)
		for _, file in ipairs(files) do
			local source = table.concat(vim.fn.readfile(file), "\n")
			-- `i18n.name` on its own, not in a path such as `leetcode.i18n.en`.
			for before, name in source:gmatch("([%w_%.]*)i18n%.([%a_][%w_]*)") do
				if before == "" and name ~= "locale" and en[name] == nil and not seen[name] then
					seen[name] = true
					missing[#missing + 1] = file .. ": " .. name
				end
			end
		end
		table.sort(missing)
		return missing
	]])
	eq(missing, {})
end

T["names"]["a name that does not exist is an error"] = function()
	eq(
		child.lua_get(
			[[select(2, pcall(function() return require("leetcode.i18n").no_such_text end)):find("no text named `no_such_text`", 1, true) ~= nil]]
		),
		true
	)
end

T["names"]["chinese falls back to english for what it lacks"] = function()
	run([[
		require("leetcode.config").translator = true
		require("leetcode.i18n.zh").continue = nil
	]])
	eq(child.lua_get([[require("leetcode.i18n").continue]]), "Continue")
	eq(child.lua_get([[require("leetcode.i18n").back]]), "返回")
end

T["names"]["english is the default"] = function()
	eq(child.lua_get([[require("leetcode.i18n").locale()]]), "en")
	eq(child.lua_get([[require("leetcode.i18n").tab_result]]), "Result")
	chinese()
	eq(child.lua_get([[require("leetcode.i18n").locale()]]), "zh")
	eq(child.lua_get([[require("leetcode.i18n").tab_result]]), "测试结果")
end

--- Opens the menu, signed in.
local function open_menu()
	run([[
		_G.cookie = { csrftoken = "x" }
		menu = require("leetcode.ui.menu")
		menu.win.buf = vim.api.nvim_get_current_buf()
		menu.win:show()
		menu.render()
		vim.wait(100, function() reactive.flush(); return menu.page() ~= "loading" end, 5)
		reactive.flush()
	]])
end

local function menu_has(text)
	return child.lua_get(("contains(menu.win.buf, %q)"):format(text))
end

local accepted = [[{
	_ = { title = require("leetcode.translator")("Accepted"), hl = "leetcode_ok", success = true, submission = false },
	status_code = 10, status_runtime = "0 ms", submission_id = "run1", total_testcases = 2,
	code_answer = { "[0,1]", "[0,1]" }, expected_code_answer = { "[0,1]", "[0,1]" },
	std_output_list = { "hello\n", "" },
}]]

local runtime_error = [[{
	_ = { title = "Runtime Error", hl = "leetcode_error", submission = true, params = {} },
	status_code = 15, full_runtime_error = "boom", last_testcase = "[1]\n2", std_output = "",
}]]

local function show_result(item)
	run(([[
		open_problem()
		problem.console:show("result")
		reactive.flush()
		problem.console.testcase:snapshot("run1", { test_case = "[2,7]\n9\n[3,3]\n6" })
		problem.console.result:handle(%s)
		reactive.flush()
	]]):format(item))
end

local function console_text()
	return table.concat(child.lua_get("buffer_text(problem.console.win.buf)"), "\n")
end

T["chinese"] = new_set()

T["chinese"]["the menu"] = function()
	chinese()
	open_menu()
	eq(menu_has("题库"), true)
	eq(menu_has("统计"), true)
	eq(menu_has("账户"), true)
	eq(menu_has("每日一题"), true)
	eq(menu_has("Problems"), false)
end

T["chinese"]["the console, with nothing left in english"] = function()
	chinese()
	show_result(accepted)
	local text = console_text()
	for _, chinese_text in ipairs({
		"测试用例",
		"测试结果",
		"通过",
		"用例 1",
		"输入",
		"输出",
		"预期结果",
		"标准输出",
	}) do
		eq({ chinese_text, text:find(chinese_text, 1, true) ~= nil }, { chinese_text, true })
	end
	for _, english in ipairs({
		"Testcase",
		"Result",
		"Case 1",
		"Input",
		"Output",
		"Expected",
		"Stdout",
		"Accepted",
		"line",
	}) do
		eq({ english, text:find(english, 1, true) ~= nil }, { english, false })
	end
end

T["chinese"]["the testcases and how to get a result"] = function()
	chinese()
	run([[
		open_problem()
		problem.console:show("result")
		reactive.flush()
	]])
	local text = console_text()
	eq(text:find("运行代码，看看结果如何。", 1, true) ~= nil, true)
	eq(text:find(":Leet run 运行测试用例，:Leet submit 提交判题", 1, true) ~= nil, true)
	eq(text:find("切换", 1, true) ~= nil, true)

	run([[problem.console.tab("testcase"); reactive.flush()]])
	text = console_text()
	eq(text:find("a 添加  d 删除  r 重置  i 编辑", 1, true) ~= nil, true)
end

T["chinese"]["the judge at work"] = function()
	chinese()
	run([[
		open_problem()
		problem.console:show("result")
		problem.console.result:judging(false)
		reactive.flush()
	]])
	local text = console_text()
	eq(text:find("正在运行测试用例", 1, true) ~= nil, true)
	eq(text:find("排队中", 1, true) ~= nil, true)
end

T["chinese"]["a run that came too soon"] = function()
	chinese()
	run([[
		open_problem()
		problem.console:show("result")
		problem.console.result:failed({ status = 429, msg = "You have attempted to run code too soon" })
		reactive.flush()
	]])
	local text = console_text()
	eq(text:find("过于频繁", 1, true) ~= nil, true)
	eq(text:find("你的提交过于频繁，请稍后再试", 1, true) ~= nil, true)
	eq(text:find("请稍等片刻，再 :Leet run。", 1, true) ~= nil, true)
end

--- The line a label is on, and whether a space parts it from its value.
local function label_line(label)
	return child.lua_get(([[(function()
		for _, line in ipairs(buffer_text(problem.console.win.buf)) do
			local at = line:find(%q, 1, true)
			if at then
				return { line = line, gap = line:sub(at + #%q, at + #%q + 1) == "  " }
			end
		end
	end)()]]):format(label, label, label))
end

T["layout"] = new_set()

T["layout"]["a label keeps a gap before its value"] = function()
	show_result(runtime_error)
	eq(label_line("Last input").gap, true)
end

T["layout"]["a label keeps a gap before its value in chinese"] = function()
	chinese()
	show_result(runtime_error)
	eq(label_line("最后执行的输入").gap, true)
	-- And the values of every label start in one column.
	local columns = child.lua_get([[(function()
		local columns = {}
		for _, line in ipairs(buffer_text(problem.console.win.buf)) do
			local at = line:find("nums = ", 1, true) or line:find("target = ", 1, true)
			if at then
				columns[#columns + 1] = vim.fn.strdisplaywidth(line:sub(1, at - 1))
			end
		end
		return vim.fn.uniq(columns)
	end)()]])
	eq(#columns, 1)
end

T["locale"] = new_set()

T["locale"]["zh shows the interface in chinese on leetcode.com"] = function()
	run([[require("leetcode.config").user.ui.locale = "zh"]])
	eq(child.lua_get([[require("leetcode.config").is_cn]]), false)
	eq(child.lua_get([[require("leetcode.config").translator]]), false)
	eq(child.lua_get([[require("leetcode.i18n").locale()]]), "zh")
	eq(child.lua_get([[require("leetcode.translator")("Wrong Answer")]]), "解答错误")
	show_result(accepted)
	eq(console_text():find("测试结果", 1, true) ~= nil, true)
end

T["locale"]["en keeps english even with the leetcode.cn translator on"] = function()
	run([[
		require("leetcode.config").translator = true
		require("leetcode.config").user.ui.locale = "en"
	]])
	eq(child.lua_get([[require("leetcode.i18n").tab_result]]), "Result")
	eq(child.lua_get([[require("leetcode.translator")("Wrong Answer")]]), "Wrong Answer")
end

T["locale"]["anything else is a mistake in the config"] = function()
	run([[
		require("leetcode.config").user.ui.locale = "fr"
		ok, err = pcall(require("leetcode.config").validate)
	]])
	eq(child.lua_get("ok"), false)
	eq(child.lua_get([[tostring(err):find('Unsupported ui.locale: "fr"', 1, true) ~= nil]]), true)
end

T["translator"] = new_set()

T["translator"]["turns what LeetCode says into chinese, keeping its spaces"] = function()
	chinese()
	eq(child.lua_get([[require("leetcode.translator")(" Accepted ")]]), " 通过 ")
	eq(child.lua_get([[require("leetcode.translator")("Wrong Answer")]]), "解答错误")
	eq(
		child.lua_get([[require("leetcode.translator")("Something no one translated")]]),
		"Something no one translated"
	)
end

T["translator"]["leaves english alone when off"] = function()
	eq(child.lua_get([[require("leetcode.translator")("Accepted")]]), "Accepted")
end

return T
