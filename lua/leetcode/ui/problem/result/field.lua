local m = require("markup")
local i18n = require("leetcode.i18n")

--- Room for the longest label and two cells after it, so values line up
--- across the fields of a result, in any language.
local function label_width()
	local widest = 0
	for _, label in ipairs({ i18n.input, i18n.output, i18n.expected, i18n.last_input }) do
		widest = math.max(widest, vim.api.nvim_strwidth(label))
	end
	return widest + 2
end

--- A labelled value, which wraps beside its label. The cursor goes past the
--- label, to the value.
---@param props { label: string, children: any }
return m.component(function(props)
	return m.flex({
		m.block({
			width = label_width(),
			shrink = 0,
			snap = false,
			m.inline(props.label, "leetcode_muted"),
		}),
		m.block({ grow = 1, shrink = 1, children = props.children }),
	})
end)
