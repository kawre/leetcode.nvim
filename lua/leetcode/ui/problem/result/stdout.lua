local m = require("markup")
local ui = require("leetcode.ui.util")

---@param props { stdout: string }
local Stdout = m.component(function(props)
	local expanded = m.signal(true)

	local std_lines = Markup.list(vim.split(props.stdout or "", "\n", { trimempty = true }))

	if #std_lines == 0 then
		return
	end

	return m.block({
		m.block({
			width = "fit",
			click = "double",
			on_press = function()
				expanded(not expanded())
			end,
			m.inline(function()
				return ui.chevron(expanded())
			end, "leetcode_muted"),
			m.inline("Stdout", "leetcode_muted"),
		}),
		m.collapse(expanded, function()
			return m.block({
				padding = { 0, 2 },
				children = std_lines:map(function(line)
					return m.block(line)
				end),
			})
		end),
	})
end)

return Stdout
