local m = require("markup")

return m.component(function()
    local spinner = m.frames({ "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" })

    return m.block({
        m.inline(spinner, "leetcode_accent"),
        m.inline(" Signing in", "leetcode_muted"),
    })
end)
