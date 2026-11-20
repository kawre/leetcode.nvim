local m = require("markup")
local i18n = require("leetcode.i18n")
local Field = require("leetcode.ui.problem.result.field")

---@param props { input: string[], params?: table[], title?: string }
local Input = m.component(function(props)
	local params = props.params or {}

	return Field({
		label = props.title or i18n.input,
		children = Markup.list(props.input):map(function(value, i)
			local param = params[i]
			return m.block({
				param and m.inline({ param.name .. " = ", style = "leetcode_muted", snap = false }),
				m.inline(value),
			})
		end),
	})
end)

return Input
