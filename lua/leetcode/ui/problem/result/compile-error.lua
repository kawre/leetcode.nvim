local m = require("markup")

---@param props { item: lc.compile_error }
local CompileError = m.component(function(props)
	return m.block({
		padding = { 0, 3 },
		style = "leetcode_error",
		children = Markup.list(vim.split(props.item.full_compile_error, "\n")):map(function(line)
			return m.block(line)
		end),
	})
end)

return CompileError
