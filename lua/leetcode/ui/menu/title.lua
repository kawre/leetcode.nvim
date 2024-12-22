local markup = require("markup")

return markup.Component(function(props)
    local page = props.page

    local titles = {}
    local parts = vim.split(page, ".", { plain = true })

    for i, title in ipairs(parts) do
        title = title:gsub("^%l", string.upper)
        local hl = i == #parts and "leetcode_menu_title" or "leetcode_menu_title_inactive"
        table.insert(titles, markup.Inline(title, hl))

        if i ~= #parts then
            table.insert(titles, markup.Inline("  ", "leetcode_menu_title_deli"))
        end
    end

    return markup.HFlex({
        children = titles,
    })
end)
