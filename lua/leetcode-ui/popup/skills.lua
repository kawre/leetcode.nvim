local Popup = require("leetcode-ui.popup")
local Group = require("leetcode-ui.group")
local Lines = require("leetcode-ui.lines")

local stats_api = require("leetcode.api.statistics")
local config = require("leetcode.config")
local Spinner = require("leetcode.logger.spinner")
local utils = require("leetcode-ui.utils")

local log = require("leetcode.logger")

---@class lc.ui.SkillsPopup : lc.ui.Popup
---@field renderer lc-ui.Renderer
local Skills = Popup:extend("LeetSkills")

function Skills:handle(name, skills)
    local lines = Lines()

    table.sort(skills, function(a, b)
        return a.problems_solved > b.problems_solved
    end)
    lines:append(config.icons.square, utils.diff_to_hl(name))
    lines:append(" " .. name)

    for _, skill in ipairs(skills) do
        lines:endl()
        lines:append(skill.tag, "leetcode_code")
        lines:append((" x%d"):format(skill.problems_solved), "leetcode_alt")
    end

    return lines
end

---@private
---@param res lc.Skills.Res
function Skills:populate(res)
    local group = Group({}, { spacing = 1 })

    local order = { "advanced", "intermediate", "fundamental" }
    for _, key in ipairs(order) do
        group:insert(self:handle(key, res[key]))
    end

    self.renderer:insert(group)
end

function Skills:mount()
    Skills.super.mount(self)

    local spinner = Spinner:init("fetching user skills", "dot")
    stats_api.skills(function(res, err)
        if err then
            spinner:stop(err.msg, false)
        else
            self:populate(res)
            spinner:stop(nil, true, { timeout = 200 })
            Skills.super.draw(self)
        end
    end)
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
end

return Skills()
