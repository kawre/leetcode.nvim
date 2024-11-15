local markup = require("markup")

local function Button(icon, title, key, nested)
    return markup.Inline({
        markup.Inline(icon, "leetcode_menu_button_icon"),
        markup.Inline(" "),
        markup.Inline(title, "leetcode_menu_button_title"),
        markup.Inline(nested and " " or "", "leetcode_menu_button_nested"),
        markup.Inline("                              "),
        markup.Inline(key, "leetcode_menu_button_key"),
    })
end

return function()
    return markup.Flex({
        spacing = 1,
        children = {
            Button("", "Problems", "p", true),
            Button("", "Statistics", "s", true),
            Button("󰆘", "Cookie", "i", true),
            Button("", "Cache", "c", true),
            Button("󰩈", "Exit", "qa"),
        },
    })
end
