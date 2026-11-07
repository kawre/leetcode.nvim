local m = require("markup")

--- Pages named for the code rather than for reading.
local names = { signin = "Welcome", loading = "Welcome" }

return m.component(function()
    local function titles()
        local page = Leet.menu.page()
        local titles = {}
        local parts = vim.split(page, ".", { plain = true })

        for i, title in ipairs(parts) do
            title = names[title] or title:gsub("^%l", string.upper)
            local last = i == #parts
            table.insert(titles, m.inline(title, last and "leetcode_strong" or "leetcode_muted"))

            if not last then
                table.insert(titles, m.inline(" \u{eab6} ", "leetcode_muted"))
            end
        end

        return titles
    end

    return m.flex({ margin_bottom = 1, padding = { 0, 1 }, titles })
end)
