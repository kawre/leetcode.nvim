local Popup = require("leetcode-ui.popup")
local Group = require("leetcode-ui.group")
local Lines = require("leetcode-ui.lines")
local t = require("leetcode.translator")

local config = require("leetcode.config")
local stats_api = require("leetcode.api.statistics")
local Spinner = require("leetcode.logger.spinner")

local log = require("leetcode.logger")

---@class lc.ui.LanguagesPopup : lc.ui.SkillsPopup
---@field renderer lc-ui.Renderer
local Languages = Popup:extend("LeetLanguages")

function Languages:handle(lang)
    local lines = Lines()

    lines:append(lang.lang, "leetcode_code")
    lines:append(" - ", "leetcode_list")
    if config.is_cn then
        lines:append("解题数", "leetcode_alt")
        lines:append(" " .. lang.problems_solved)
    else
        lines:append("" .. lang.problems_solved)
        lines:append(" problems solved", "leetcode_alt")
    end

    return lines
end

---@private
---@param res lc.Languages.Res
function Languages:populate(res)
    local group = Group({ spacing = 1 })

    table.sort(res, function(a, b) return a.problems_solved > b.problems_solved end)
    for _, lang in ipairs(res) do
        group:insert(self:handle(lang))
    end

    self.renderer:append(group)
end

function Languages:mount()
    Languages.super.mount(self)

    local spinner = Spinner:init("fetching user languages", "dot")
    stats_api.languages(function(res, err)
        if err then
            spinner:stop(err.msg, false)
        else
            self:populate(res)
            spinner:stop(nil, true, { timeout = 500 })
            self.renderer:draw()
        end
    end)
end

function Languages:init()
    Languages.super.init(self, {
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
                top = (" %s "):format(t("Languages")),
            },
        },
        buf_options = {
            modifiable = false,
            readonly = false,
        },
    })
end

return Languages()
