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

---@param props { stdout: string }
local Stdout = m.component(function(props)
	local expanded = m.signal(true)

	local lines = vim.split(props.stdout or "", "\n", { trimempty = true })
	if #lines == 0 then
		return
	end

	local hovered = m.signal(false)

	return m.block({
		margin_top = 1,
		padding = { 0, 1 },
		style = "leetcode_section",
		border = "half",
		m.flex({
			justify = "between",
			m.block({
				width = "fit",
				click = "double",
				on_press = function()
					expanded(not expanded())
				end,
				m.inline(function()
					return ui.chevron(expanded())
				end, "leetcode_muted"),
				m.inline(ICONS.stdout .. " ", "leetcode_accent"),
				m.inline("Stdout", "leetcode_strong"),
				m.inline(("  %d %s"):format(#lines, #lines == 1 and "line" or "lines"), "leetcode_muted"),
			}),
			m.inline({
				click = "double",
				on_press = function()
					fullscreen(lines)
				end,
				on_hover = hovered,
				style = function()
					return hovered() and "leetcode_accent" or "leetcode_muted"
				end,
				ICONS.fullscreen,
			}),
		}),
		m.collapse(expanded, function()
			return m.block({
				padding = { 1, 0, 0, 2 },
				vim.tbl_map(function(line)
					return m.block(line)
				end, lines),
			})
		end),
	})
end)

return Stdout
