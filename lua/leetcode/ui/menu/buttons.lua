local markup = require("markup")

local function Button(icon, title, key)
    return markup.Inline({
        markup.Inline(icon, "leetcode_menu_button_icon"),
        markup.Inline(" "),
        markup.Inline(title, "leetcode_menu_button_title"),
        markup.Inline("                              "),
        markup.Inline(key, "leetcode_menu_button_key"),
    })
end

return function()
    return markup.Flex({
        spacing = 1,
        children = {
            Button("", "Problems", "p"),
            Button("", "Statistics", "p"),
            Button("󰆘", "Cookie", "p"),
            Button("", "Cache", "p"),
            Button("󰩈", "Exit", "p"),
        },
    })
end
