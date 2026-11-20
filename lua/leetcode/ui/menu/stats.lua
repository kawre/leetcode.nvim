--- The page beside the dashboard, which slides in from the right.

local m = require("markup")
local kit = require("leetcode.ui.kit")
local data = require("leetcode.ui.menu.data")
local PageBar = require("leetcode.ui.menu.page_bar")
local solved = require("leetcode.ui.menu.solved")
local Heatmap = require("leetcode.ui.menu.heatmap")
local t = require("leetcode.translator")

--- Tags shown per level, the rest is only counted.
local TOP_SKILLS = 6
local TOP_LANGUAGES = 5

local levels = {
	{ key = "fundamental", title = "Fundamental", hl = "leetcode_easy" },
	{ key = "intermediate", title = "Intermediate", hl = "leetcode_medium" },
	{ key = "advanced", title = "Advanced", hl = "leetcode_hard" },
}

local function by_solved(items)
	local sorted = vim.deepcopy(items)
	table.sort(sorted, function(a, b)
		return a.problems_solved > b.problems_solved
	end)
	return sorted
end

--- How long `Updated` shows before the button is plain again.
local UPDATED_FOR = 1500

local function Bar(width)
	local state = m.signal("idle")

	local function back()
		Leet.menu.set_page("menu")
	end

	local function update()
		if state() == "busy" then
			return
		end

		state("busy")
		data.update(function()
			state("done")
			vim.defer_fn(function()
				if state() == "done" then
					state("idle")
				end
			end, UPDATED_FOR)
		end)
	end

	local function progress()
		local current = state()
		if current == "busy" then
			return m.inline({ m.loader(), m.inline(" Updating") })
		elseif current == "done" then
			-- In the colors of the button, which may be lit by the cursor.
			return m.inline(kit.icons.check .. " Updated")
		end
	end

	return PageBar({
		title = "Statistics",
		width = width,
		actions = {
			{ title = "Update", lhs = "u", press = update, content = progress },
			{ title = "Back", lhs = "q", press = back },
		},
	})
end

local function Skill(skill)
	return m.flex({
		justify = "between",
		white_space = "nowrap",
		m.inline({ shrink = 1, m.inline(skill.tag, "leetcode_alt") }),
		m.inline({
			shrink = 0,
			margin_left = 1,
			m.inline(tostring(skill.problems_solved), "leetcode_strong"),
		}),
	})
end

local function Level(level, width)
	return m.block({
		width = width,
		m.block({ margin_bottom = 1, m.inline(t(level.title), level.hl) }),
		function()
			local skills = data.skills()
			if not skills then
				return m.block(kit.Loading())
			end

			local sorted = by_solved(skills[level.key] or {})
			if #sorted == 0 then
				return m.block("Nothing yet", "leetcode_muted")
			end

			local rows = vim.tbl_map(Skill, vim.list_slice(sorted, 1, TOP_SKILLS))
			if #sorted > TOP_SKILLS then
				rows[#rows + 1] =
					m.block(("+%d more"):format(#sorted - TOP_SKILLS), "leetcode_muted")
			end
			return m.block(rows)
		end,
	})
end

--- One card, with a column for each level or the levels below each other.
local function Skills(width, columns)
	local inner = width - 4
	local level_width = columns and 23 or inner

	local items = vim.tbl_map(function(level)
		return Level(level, level_width)
	end, levels)

	return kit.HoverCard({
		width = width,
		columns and m.flex({ justify = "between", items }) or m.vflex({ spacing = 1, items }),
	})
end

local function Language(language, index, most, bar_width)
	local info = Leet.util.get_lang_by_name(language.lang)

	return m.flex({
		white_space = "nowrap",
		m.inline({
			width = 16,
			shrink = 0,
			info and m.inline(info.icon .. " ", info.hl or "leetcode_accent"),
			m.inline(info and info.lang or language.lang, "leetcode_alt"),
		}),
		kit.Bar({
			width = bar_width,
			delay = 180 + index * 70,
			style = "leetcode_bar_accent",
			value = function()
				return language.problems_solved / math.max(most, 1)
			end,
		}),
		m.inline({
			margin_left = 2,
			m.inline(tostring(language.problems_solved), "leetcode_strong"),
		}),
	})
end

local function Languages(width)
	return kit.HoverCard({
		width = width,
		m.block({ margin_bottom = 1, m.inline(t("Languages"), "leetcode_muted") }),
		function()
			local languages = data.languages()
			if not languages then
				return m.block(kit.Loading())
			end
			if #languages == 0 then
				return m.block("Nothing yet", "leetcode_muted")
			end

			local sorted = by_solved(languages)
			local most = sorted[1].problems_solved
			local rows = {}
			for i, language in ipairs(vim.list_slice(sorted, 1, TOP_LANGUAGES)) do
				rows[i] = Language(language, i, most, width - 28)
			end
			return m.vflex({ spacing = 1, rows })
		end,
	})
end

--- `props.width` is the room for all of it, and `props.columns` says if the levels
--- fit side by side.
return m.component(function(props)
	local width = props.width

	if not m.untrack(data.skills) then
		data.load_details()
	end

	return m.vflex({
		align = "center",
		margin_top = 1,
		Bar(width),
		solved.Solved({ width = width }),
		props.columns and Heatmap({ width = width }),
		Skills(width, props.columns),
		Languages(width),
	})
end)
