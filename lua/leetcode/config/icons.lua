local icons = {
    bar = "│",
    circle = "",
    square = "󱓻",
    lock = "",
    unlock = "",
    star = "",
    status = {
        ac = "",
        notac = "󱎖",
        todo = "",
    },
    caret = {
        right = "",
    },
}

icons.hl = {
    status = {
        ac = { icons.status.ac, "leetcode_easy" },
        notac = { icons.status.notac, "leetcode_medium" },
        todo = { icons.status.todo, "leetcode_alt" },
    },
    lock = { icons.lock, "leetcode_medium" },
    unlock = { icons.unlock, "leetcode_medium" },
}

icons.indent = ("\t%s "):format(icons.bar)

return icons
