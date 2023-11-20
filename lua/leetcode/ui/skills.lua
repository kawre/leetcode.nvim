local Popup = require("leetcode.ui.popup")
local NuiLine = require("nui.line")
local Group = require("leetcode-ui.component.group")
local Text = require("leetcode-ui.component.text")

local stats_api = require("leetcode.api.statistics")
local Spinner = require("leetcode.logger.spinner")
local Layout = require("leetcode-ui.layout")

local log = require("leetcode.logger")

---@class lc.ui.SkillsPopup : lc.ui.Popup
---@field layout lc-ui.Layout
local Skills = Popup:extend("LeetSkills")

local hl = {
    advanced = "leetcode_hard",
    intermediate = "leetcode_medium",
    fundamental = "leetcode_easy",
}

function Skills:handle(name, skills)
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
function Skills:populate(res)
    local group = Group:init({}, { spacing = 2 })

    local order = { "advanced", "intermediate", "fundamental" }
    for _, key in ipairs(order) do
        group:append(self:handle(key, res[key]))
    end

    self.layout:append(group)
end

function Skills:init()
    Skills.super.init(self, {
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

    self.layout = Layout:init({})
end

function Skills:show()
    if not self._.mounted then
        local spinner = Spinner:init("fetching user skills", "dot")
        stats_api.skills(function(res, err)
            if err then
                spinner:stop(err.msg, false)
            else
                self:populate(res)
                spinner:stop(nil, true, { timeout = 200 })
                self.layout:draw(self)
            end
        end)
    end

    Skills.super.show(self)
end

return Skills()
