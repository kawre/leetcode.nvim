local markup = require("markup")

return function(history)
    local titles = {}

    for i, title in ipairs(history or {}) do
        title = title:gsub("^%l", string.upper)
        local hl = i == #history and "leetcode_menu_title" or "leetcode_menu_title_inactive"
        table.insert(titles, markup.Inline(title, hl))

        if i ~= #history then
            table.insert(titles, markup.Inline("  ", "leetcode_menu_title_separator"))
        end
    end

    return markup.Flex({
        vertical = false,
        children = titles,
    })
end
