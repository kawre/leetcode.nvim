local m = require("markup")

return m.Component(function()
    local menu = m.use(Leet.ctx.menu)
    local page = menu.page

    local titles = {}
    local parts = vim.split(page, ".", { plain = true })

    for i, title in ipairs(parts) do
        title = title:gsub("^%l", string.upper)
        local hl = i == #parts and "leetcode_menu_title" or "leetcode_menu_title_inactive"
        table.insert(titles, m.Inline(title, hl))

        if i ~= #parts then
            table.insert(titles, m.Inline("  "))
        end
    end

    return m.flex({
        -- width = 50,
        justify = "center",
        children = titles,
    })
end)
