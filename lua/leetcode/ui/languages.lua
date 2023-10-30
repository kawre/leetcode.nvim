local NuiPopup = require("nui.popup")
local NuiLine = require("nui.line")
local Group = require("leetcode-ui.component.group")
local Text = require("leetcode-ui.component.text")

local stats_api = require("leetcode.api.statistics")
local Spinner = require("leetcode.logger.spinner")
local Layout = require("leetcode-ui.layout")

local log = require("leetcode.logger")

---@class lc.ui.Languages
---@field _ NuiPopup
---@field mounted boolean
---@field layout lc-ui.Layout
local Languages = {}

Languages.mounted = false

function Languages.show()
    if Languages.mounted then
        Languages._:show()
    else
        Languages.mount()
    end
end

function Languages.handle(lang)
    local text = Text:init({})

    local line = NuiLine()
    line:append(lang.lang, "leetcode_code")
    line:append(" - ", "leetcode_list")
    line:append("" .. lang.problems_solved)
    line:append(" problems solved", "leetcode_alt")

    text:append(line)
    return text
end

---@private
---@param res lc.Languages.Res
function Languages.populate(res)
    local group = Group:init({}, { spacing = 2 })

    table.sort(res, function(a, b) return a.problems_solved > b.problems_solved end)
    for _, lang in ipairs(res) do
        group:append(Languages.handle(lang))
    end

    Languages.layout:append(group)
end

function Languages.mount()
    Languages.layout = Layout:init({})

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
                top = " Languages ",
            },
        },
        buf_options = {
            modifiable = false,
            readonly = false,
        },
    })

    popup:map("n", { "q", "<Esc>" }, function() popup:hide() end, { nowait = true })
    Languages._ = popup

    local spinner = Spinner:init("fetching user languages", "dot")
    stats_api.languages(function(res)
        Languages.populate(res)
        spinner:stop(nil, true)
        Languages.layout:draw(Languages._)
    end)

    popup:mount()
    Languages.mounted = true
end

return Languages
