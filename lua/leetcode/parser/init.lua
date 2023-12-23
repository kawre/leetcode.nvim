local Object = require("nui.object")

local Tag = require("leetcode-ui.group.tag")
local Plain = require("leetcode.parser.plain")
local log = require("leetcode.logger")

---@class lc.Parser
local Parser = Object("LeetParser")

---@param text string
---@return lc.ui.Group
function Parser.static:parse(text)
    local check_for_html = function()
        local parsers = require("nvim-treesitter.parsers")
        assert(parsers.get_parser_configs()["html"])
    end

    if pcall(check_for_html) then
        return Tag:parse(text)
    else
        return Plain:parse(text)
    end
end

---@type fun(): lc.Parser
local LeetParser = Parser

return LeetParser
