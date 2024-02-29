local Group = require("leetcode-ui.group")
local Tag = require("leetcode-ui.group.tag")
local Line = require("leetcode-ui.line")
local u = require("leetcode.parser.utils")

---@class lc.Parser.Plain : lc.ui.Group
---@field text string
local Plain = Group:extend("LeetParserPlain")

function Plain.normalize(text)
    return text:gsub("<[^>]+>", "")
end

---@param text string
function Plain:init(text)
    Plain.super.init(self)

    for s in vim.gsplit(Plain.normalize(text), "\n") do
        s = s:gsub("&[%a%d#]+;", u.entity)
        self:append(s)
        self:endl()
    end
end

---@type fun(text: string)
local LeetParserPlain = Plain

---@param text string
function Plain.static:parse(text)
    return LeetParserPlain(text)
end

return LeetParserPlain
