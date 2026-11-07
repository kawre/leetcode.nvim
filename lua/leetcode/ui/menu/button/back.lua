local m = require("markup")
local Item = require("leetcode.ui.menu.item")

return m.component(function(props)
    return Item({ icon = "\u{f053}", title = "Back", desc = "return to the menu", lhs = "q", page = props.page })
end)
