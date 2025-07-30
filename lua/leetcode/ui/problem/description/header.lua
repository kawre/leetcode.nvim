local markup = require("markup")
local utils = require("leetcode.utils")
local config = require("leetcode.config")
local t = require("leetcode.translator")
local icons = config.icons

local function hl(str)
    local prefix = "leetcode_description_header"
    if not str then
        return prefix
    end
    return table.concat({ prefix, str }, "_")
end

local Title = markup.Component(function(self)
    ---@type lc.QuestionResponse
    local info = self.props
    local title = utils.translate(info.title, info.translated_title)

    return markup.HFlex({
        spacing = 1,
        children = {
            markup.Inline(info.frontend_id .. ".", "leetcode_normal"),
            markup.Inline(title, hl("title")),
            markup.If(info.is_paid_only, markup.Inline(t("Premium"), "leetcode_medium")),
        },
    })
end)

local Stats = markup.Component(function(self)
    ---@type lc.QuestionResponse, lc.cache.Question
    local info, cache = self.props.info, self.props.cache

    local diff = info.difficulty
    local status = cache.status
    local dislikes = info.dislikes
    local likes = info.likes

    local ac_rate = info.stats.acRate
    local total_sub = info.stats.totalSubmission
    local hints = info.hints

    return markup.HFlex({
        spacing = 1,
        children = {
            markup.Inline(diff, "leetcode_" .. diff:lower()),
            markup.Inline(icons.bar, hl("deli")),
            markup.Inline(likes, hl("stat")),
            markup.Inline(icons.like),
            markup.Inline(dislikes, hl("stat")),
            markup.Inline(icons.dislike),
            markup.Inline(icons.bar, hl("deli")),
            markup.Inline(ac_rate, hl("stat")),
            markup.Inline("of"),
            markup.Inline(total_sub),
            markup.If(not vim.tbl_isempty(hints), {
                markup.Inline(icons.bar, hl("deli")),
                markup.Inline("󰛨 " .. t("Hints"), hl("hint")),
            }),
        },
    })
end)

return markup.Component(function(self)
    local cache, info = self.props.cache, self.props.info

    return markup.Flex({
        align = "center",
        spacing = 1,
        margin = { 1, 0, 2 },
        style = { link = hl() },
        children = {
            Title(info),
            Stats({ cache = cache, info = info }),
        },
    })
end)
