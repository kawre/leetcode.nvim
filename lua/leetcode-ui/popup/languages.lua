local Popup = require("leetcode-ui.popup")
local Group = require("leetcode-ui.group")
local Lines = require("leetcode-ui.lines")

local log = require("leetcode.logger")
local t = require("leetcode.translator")

local utils = require("leetcode.utils")
local config = require("leetcode.config")
local stats_api = require("leetcode.api.statistics")
local Spinner = require("leetcode.logger.spinner")

---@class lc.ui.LanguagesPopup : lc.ui.SkillsPopup
---@field renderer lc.ui.Renderer
local Languages = Popup:extend("LeetLanguages")

function Languages:handle(res)
    local lines = Lines()

    local lang = utils.get_lang_by_name(res.lang)

    if lang then
        lines:append(lang.icon .. " " .. lang.lang, lang.hl or "leetcode_code")
    else
        lines:append(res.lang, "leetcode_code")
    end

    lines:append(" - ", "leetcode_list")

    if config.translator then
        lines:append("解题数", "leetcode_alt")
        lines:append(" " .. res.problems_solved)
    else
        lines:append("" .. res.problems_solved)
        lines:append(" problems solved", "leetcode_alt")
    end

    return lines
end

---@private
---@param res lc.Languages.Res
function Languages:populate(res)
    local group = Group({}, { spacing = 1 })
    if res == vim.NIL then
        return
    end

    table.sort(res, function(a, b)
        return a.problems_solved > b.problems_solved
    end)
    for _, lang in ipairs(res) do
        group:insert(self:handle(lang))
    end

    self.renderer:insert(group)
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
            Languages.super.draw(self)
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
