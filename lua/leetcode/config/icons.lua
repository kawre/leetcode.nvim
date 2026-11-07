local icons = {
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
    },
    lock = { icons.lock, "leetcode_medium" },
    unlock = { icons.unlock, "leetcode_medium" },
}


return icons
