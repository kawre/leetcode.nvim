local m = require("markup")

return m.component(function()
    local menu = m.hooks.use(Leet.ctx.menu)
    local page = menu.page

    local titles = {}
    local parts = vim.split(page, ".", { plain = true })

    for i, title in ipairs(parts) do
        title = title:gsub("^%l", string.upper)
        local hl = i == #parts and "Label" or "Type"
        table.insert(titles, m.inline(title, hl))

        if i ~= #parts then
            table.insert(titles, m.inline("  "))
        end
    end

    return m.flex({
        -- width = 50,
        justify = "center",
        children = titles,
    })
end)
