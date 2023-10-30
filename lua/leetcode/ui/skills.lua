local NuiPopup = require("nui.popup")
local NuiLine = require("nui.line")
local Group = require("leetcode-ui.component.group")
local Text = require("leetcode-ui.component.text")

local stats_api = require("leetcode.api.statistics")
local Spinner = require("leetcode.logger.spinner")
local Layout = require("leetcode-ui.layout")

local log = require("leetcode.logger")

---@class lc.ui.Skills
---@field _ NuiPopup
---@field mounted boolean
---@field layout lc-ui.Layout
local Skills = {}

Skills.mounted = false

function Skills.show()
    if Skills.mounted then
        Skills._:show()
    else
        Skills.mount()
    end
end

local hl = {
    advanced = "leetcode_hard",
    intermediate = "leetcode_medium",
    fundamental = "leetcode_easy",
}

function Skills.handle(name, skills)
    local adv = Text:init({})

    table.sort(skills, function(a, b) return a.problems_solved > b.problems_solved end)
    local adv_line = NuiLine()
    adv_line:append("󱓻", hl[name])
    adv_line:append(" " .. name)
    adv:append(adv_line)

    for _, skill in ipairs(skills) do
        local tag_line = NuiLine()
        tag_line:append(skill.tag, "leetcode_code")
        tag_line:append((" x%d"):format(skill.problems_solved), "leetcode_alt")

        adv:append(tag_line)
    end

    return adv
end

---@private
---@param res lc.Skills.Res
function Skills.populate(res)
    local group = Group:init({}, { spacing = 2 })

    local order = { "advanced", "intermediate", "fundamental" }
    for _, key in ipairs(order) do
        group:append(Skills.handle(key, res[key]))
    end

    Skills.layout:append(group)
end

function Skills.mount()
    Skills.layout = Layout:init({})

    local popup = NuiPopup({
        position = "50%",
        size = {
            width = 75,
            height = "50%",
        },
        enter = true,
        focusable = true,
        zindex = 50,
        relative = "editor",
        border = {
            padding = {
                top = 2,
                bottom = 2,
                left = 3,
                right = 3,
            },
            style = "rounded",
            text = {
                top = " Skills ",
            },
        },
        buf_options = {
            modifiable = false,
            readonly = false,
        },
    })

    popup:map("n", { "q", "<Esc>" }, function() popup:hide() end, { nowait = true })
    Skills._ = popup

    local spinner = Spinner:init("fetching user skills", "dot")
    stats_api.skills(function(res)
        Skills.populate(res)
        spinner:stop(nil, true)
        Skills.layout:draw(Skills._)
    end)

    popup:mount()
    Skills.mounted = true
end

return Skills
