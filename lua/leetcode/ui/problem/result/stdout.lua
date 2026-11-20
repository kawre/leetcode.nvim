local m = require("markup")
local ui = require("leetcode.ui.util")

local ICONS = {
	stdout = "\u{f018d}",
	fullscreen = "\u{f0293}",
}

--- Opens the output in a large popup over a dimmed editor, as plain text that
--- can be searched and copied.
---@param lines string[]
local function fullscreen(lines)
	local win = Markup.window({
		position = "float",
		width = 0.8,
		height = 0.8,
		border = "rounded",
		title = (" %s Stdout "):format(ICONS.stdout),
		title_pos = "center",
		footer = " q close ",
		footer_pos = "center",
		backdrop = 60,
		enter = true,
		minimal = true,
		text = lines,
		bo = { modifiable = false, filetype = "leetcode.stdout" },
		-- A column of room on the left, away from the border.
		wo = { wrap = true, cursorline = true, statuscolumn = " " },
	})
	for _, lhs in ipairs({ "q", "<Esc>" }) do
		win:map("n", lhs, function()
			win:close()
		end)
	end
	return win
end

--- A press that opens the whole output.
---@param lines string[]
---@param label string
local function FullscreenButton(lines, label)
	local hovered = m.signal(false)
	return m.inline({
		click = "double",
		on_press = function()
			fullscreen(lines)
		end,
		on_hover = hovered,
		style = function()
			return hovered() and "leetcode_accent" or "leetcode_muted"
		end,
		ICONS.fullscreen .. " " .. label,
	})
end

local function plural(count, word)
	return ("%d %s%s"):format(count, word, count == 1 and "" or "s")
end

---@param props { stdout: string }
local Stdout = m.component(function(props)
	local expanded = m.signal(true)

	local lines = vim.split(props.stdout or "", "\n", { trimempty = true })
	if #lines == 0 then
		return
	end

	m.use_key("f", function()
		fullscreen(lines)
	end)

	-- A long output would push everything else out of the console.
	local limit = math.max(Leet.config.user.console.result.stdout_lines or 50, 1)
	local shown = vim.list_slice(lines, 1, limit)
	local hidden = #lines - #shown

	return m.block({
		padding = { 0, 1 },
		style = "leetcode_section",
		border = "half",
		m.flex({
			justify = "between",
			m.block({
				width = "fit",
				m.inline({
					click = "double",
					on_press = function()
						expanded(not expanded())
					end,
					m.inline(function()
						return ui.chevron(expanded())
					end, "leetcode_muted"),
					m.inline(ICONS.stdout .. " ", "leetcode_accent"),
					m.inline("Stdout", "leetcode_strong"),
				}),
				-- Beside the button rather than in it, as the cursor goes
				-- anywhere inside a button, and the count is only to read.
				m.inline({ "  " .. plural(#lines, "line"), style = "leetcode_muted", snap = false }),
			}),
			m.inline({
				FullscreenButton(lines, "Fullscreen"),
				m.inline({ "  f", style = "leetcode_key", snap = false }),
			}),
		}),
		m.collapse(expanded, function()
			return m.block({
				padding = { 1, 0, 0, 2 },
				vim.tbl_map(function(line)
					return m.block(line)
				end, shown),
				hidden > 0 and m.block({
					margin_top = 1,
					m.inline({
						"… " .. plural(hidden, "more line") .. "  ",
						style = "leetcode_muted",
						snap = false,
					}),
					FullscreenButton(lines, "Show all"),
				}),
			})
		end),
	})
end)

return Stdout
