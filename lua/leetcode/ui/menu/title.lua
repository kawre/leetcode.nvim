local m = require("markup")

return m.component(function()
    local function titles()
        local page = Leet.menu.page()
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

        return titles
    end

    return m.flex({
        justify = "center",
        titles,
    })
end)
