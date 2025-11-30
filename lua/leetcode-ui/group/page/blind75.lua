local cmd = require("leetcode.command")

local Title = require("leetcode-ui.lines.title")
local Button = require("leetcode-ui.lines.button.menu")
local BackButton = require("leetcode-ui.lines.button.menu.back")
local Buttons = require("leetcode-ui.group.buttons.menu")
local Page = require("leetcode-ui.group.page")

local footer = require("leetcode-ui.lines.footer")
local header = require("leetcode-ui.lines.menu-header")

local page = Page()

page:insert(header)

page:insert(Title({ "Menu" }, "Blind 75"))

-- Define all 18 sections in order
local sections = {
    { name = "Arrays & Hashing", key = "arrays-hashing", sc = "1" },
    { name = "Two Pointers", key = "two-pointers", sc = "2" },
    { name = "Sliding Window", key = "sliding-window", sc = "3" },
    { name = "Stack", key = "stack", sc = "4" },
    { name = "Binary Search", key = "binary-search", sc = "5" },
    { name = "Linked List", key = "linked-list", sc = "6" },
    { name = "Trees", key = "trees", sc = "7" },
    { name = "Heap / Priority Queue", key = "heap", sc = "8" },
    { name = "Backtracking", key = "backtracking", sc = "9" },
    { name = "Tries", key = "tries", sc = "a" },
    { name = "Graphs", key = "graphs", sc = "b" },
    { name = "Advanced Graphs", key = "advanced-graphs", sc = "c" },
    { name = "1-D Dynamic Programming", key = "1d-dp", sc = "d" },
    { name = "2-D Dynamic Programming", key = "2d-dp", sc = "e" },
    { name = "Greedy", key = "greedy", sc = "f" },
    { name = "Intervals", key = "intervals", sc = "g" },
    { name = "Math & Geometry", key = "math-geometry", sc = "h" },
    { name = "Bit Manipulation", key = "bit-manipulation", sc = "i" },
}

local buttons = {}
for _, section in ipairs(sections) do
    table.insert(buttons, Button(section.name, {
        icon = "󰓹",
        sc = section.sc,
        on_press = function()
            cmd.blind75_section(section.key)
        end,
        expandable = true,
    }))
end

table.insert(buttons, BackButton("menu"))

page:insert(Buttons(buttons))

page:insert(footer)

return page

