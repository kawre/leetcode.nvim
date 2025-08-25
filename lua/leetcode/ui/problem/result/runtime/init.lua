local m = require("markup")
local Accepted = require("leetcode.ui.problem.result.runtime.accepted")
local Header = require("leetcode.ui.problem.result.header")
local Cases = require("leetcode.ui.problem.result.cases")

---@param props { item: lc.runtime, console: leet.problem.console }
local Runtime = m.component(function(props)
    local item = props.item

    if item._.submission then
        return Accepted(item)
    end

    return m.block({
        spacing = 1,
        Header({ item = item }),
        Cases({ item = item, console = props.console }),
    })
end)

return Runtime
