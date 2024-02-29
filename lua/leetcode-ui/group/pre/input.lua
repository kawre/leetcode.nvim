local Pre = require("leetcode-ui.group.pre")
local Group = require("leetcode-ui.group")
local Line = require("leetcode-ui.line")

local t = require("leetcode.translator")

---@class lc.ui.Input : lc.ui.Pre
local Input = Pre:extend("LeetSimilarQuestions")

---@param title string
---@param input string[]
function Input:init(title, input, params) --
    local group = Group({}, { spacing = 1 })

    for i, case in ipairs(input) do
        local ok, param = pcall(function()
            return params[i].name
        end)
        if ok then
            group:append(param .. " =", "leetcode_normal"):endl()
        end
        group:append(case):endgrp()
    end

    local title_line = Line():append(t(title), "leetcode_normal")

    Input.super.init(self, title_line, group)
end

---@type fun(title: string, input: string[], params: lc.QuestionResponse.metadata.param): lc.ui.Padding
local LeetInput = Input

return LeetInput
