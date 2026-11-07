local m = require("markup")
local Accepted = require("leetcode.ui.problem.result.runtime.accepted")
local Cases = require("leetcode.ui.problem.result.cases")

---@param props { item: lc.runtime, console: leet.problem.console }
local Runtime = m.component(function(props)
	if props.item._.submission then
		return Accepted({ item = props.item })
	end
	return Cases({ item = props.item, console = props.console })
end)

return Runtime
