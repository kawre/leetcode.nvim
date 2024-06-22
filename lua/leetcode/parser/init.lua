local Object = require("nui.object")

local Tag = require("leetcode-ui.group.tag")
local Plain = require("leetcode.parser.plain")
local log = require("leetcode.logger")

---@class lc.Parser
local Parser = Object("LeetParser")

---@param text string
---@return lc.ui.Group
function Parser.static:parse(text)
    if #vim.api.nvim_get_runtime_file("parser/html.so", true) > 0 then
        return Tag:parse(text)
    else
        return Plain:parse(text)
    end
end

---@type fun(): lc.Parser
local LeetParser = Parser

return LeetParser
