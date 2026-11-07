local m = require("markup")

local ICONS = {
	testcase = "\u{f0668}",
	result = "\u{f0b8e}",
	add = "\u{f0415}",
}

--- A pressable chip, lighter under the cursor.
---@param props { label: string|fun(): string, active: fun(): boolean, press: function, kind?: fun(): string? }
local function Chip(props)
	local hovered = m.signal(false)
	return m.inline({
		click = "double",
		on_press = props.press,
		on_hover = hovered,
		white_space = "nowrap",
		style = function()
			local kind = props.kind and props.kind()
			if props.active() then
				return kind and ("leetcode_tab_%s_active"):format(kind) or "leetcode_tab_active"
			elseif hovered() then
				return "leetcode_tab_hover"
			end
			return kind and ("leetcode_tab_%s"):format(kind) or "leetcode_tab"
		end,
		props.label,
	})
end

--- A field holding the value of one parameter. Pressing it types over it.
---@param props { console: leet.problem.console, param: integer, hovered: markup.reactive.signal }
local function Field(props)
	local testcase = props.console.testcase
	local hovered = m.signal(false)

	local function press()
		testcase:edit(props.param)
	end
	-- So typing can find where the field is.
	testcase.fields[props.param] = press
	m.on_cleanup(function()
		if testcase.fields[props.param] == press then
			testcase.fields[props.param] = nil
		end
	end)

	return m.flex({
		click = "double",
		on_press = press,
		on_hover = function(on)
			hovered(on)
			if on then
				props.hovered(props.param)
			end
		end,
		white_space = "nowrap",
		margin_bottom = 1,
		style = function()
			local typing = props.console.typing() == props.param
			return (typing or hovered()) and "leetcode_input_focus" or "leetcode_input"
		end,
		m.inline({
			"▌ ",
			style = function()
				return props.console.typing() == props.param and "leetcode_accent" or "leetcode_muted"
			end,
		}),
		m.inline(function()
			local case = testcase.cases()[testcase.selected()] or {}
			local value = case[props.param] or ""
			return value == "" and " " or value
		end),
	})
end

--- The cases to run, one at a time, with a field for each parameter.
---@param props { console: leet.problem.console }
local Testcases = m.component(function(props)
	local console = props.console
	local testcase = console.testcase
	-- The field last under the cursor, which `i` types into.
	local hovered = m.signal(1)

	for i = 1, 9 do
		m.use_key(tostring(i), function()
			testcase:select(i)
		end)
	end
	m.use_key("a", function()
		testcase:add()
	end)
	m.use_key("d", function()
		testcase:remove()
	end)
	m.use_key("r", function()
		testcase:reset()
	end)
	m.use_key("i", function()
		testcase:edit(m.untrack(hovered))
	end)

	local fields = {}
	for i, name in ipairs(testcase:names()) do
		fields[#fields + 1] = m.block({ m.inline(name .. " =", "leetcode_muted") })
		fields[#fields + 1] = Field({ console = console, param = i, hovered = hovered })
	end

	return m.block({
		padding = { 0, 3 },
		m.block({
			margin_bottom = 1,
			m.inline({
				spacing = 1,
				m.each(function()
					local list = {}
					for i = 1, #testcase.cases() do
						list[i] = i
					end
					return list
				end, function(i)
					return Chip({
						label = (" Case %d "):format(i),
						active = function()
							return testcase.selected() == i
						end,
						press = function()
							testcase:select(i)
						end,
					})
				end),
				Chip({
					label = (" %s "):format(ICONS.add),
					active = function()
						return false
					end,
					press = function()
						testcase:add()
					end,
				}),
			}),
		}),
		fields,
		m.block({
			m.inline("a", "leetcode_key"),
			m.inline(" add  ", "leetcode_muted"),
			m.inline("d", "leetcode_key"),
			m.inline(" remove  ", "leetcode_muted"),
			m.inline("r", "leetcode_key"),
			m.inline(" reset  ", "leetcode_muted"),
			m.inline("i", "leetcode_key"),
			m.inline(" edit", "leetcode_muted"),
		}),
	})
end)

--- What the last run or submission came to, or how to get one.
---@param props { console: leet.problem.console }
local function Results(props)
	return function()
		local content = props.console.result.content()
		if content then
			return content.render()
		end
		return m.block({
			padding = { 0, 3 },
			m.block({ "Run your code to see how it does.", style = "leetcode_muted" }),
			m.block({
				margin_top = 1,
				m.inline(":Leet run", "leetcode_key"),
				m.inline(" tries the testcases, ", "leetcode_muted"),
				m.inline(":Leet submit", "leetcode_key"),
				m.inline(" sends it to be judged", "leetcode_muted"),
			}),
		})
	end
end

local TABS = {
	{ key = "testcase", label = "Testcase", icon = ICONS.testcase },
	{ key = "result", label = "Result", icon = ICONS.result },
}

--- One panel below the editor: the testcases to run, and what running them did.
---@param props { console: leet.problem.console }
return m.component(function(props)
	local console = props.console

	local function switch(by)
		for i, tab in ipairs(TABS) do
			if tab.key == m.untrack(console.tab) then
				console.tab(TABS[(i - 1 + by) % #TABS + 1].key)
				return
			end
		end
	end
	m.use_key("<Tab>", function()
		switch(1)
	end)
	m.use_key("<S-Tab>", function()
		switch(-1)
	end)

	local tabs = {}
	for _, tab in ipairs(TABS) do
		tabs[#tabs + 1] = Chip({
			label = (" %s %s "):format(tab.icon, tab.label),
			active = function()
				return console.tab() == tab.key
			end,
			press = function()
				console.tab(tab.key)
			end,
		})
	end

	return m.block({
		white_space = "nowrap",
		m.flex({
			justify = "between",
			padding = { 1, 3, 0, 3 },
			margin_bottom = 1,
			m.inline({ spacing = 1, tabs }),
			m.inline({
				m.inline("<Tab>", "leetcode_key"),
				m.inline(" switch", "leetcode_muted"),
			}),
		}),
		function()
			if console.tab() == "testcase" then
				return Testcases({ console = console })
			end
			return m.block({ white_space = "normal", Results({ console = console }) })
		end,
	})
end)
