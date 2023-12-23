local Object = require("nui.object")
local Group = require("leetcode-ui.group")

local Tag = require("leetcode-ui.group.tag")
-- local plain = require("leetcode.parser.plain")
local log = require("leetcode.logger")

---@class lc.Parser
local Parser = Object("LeetParser")

function Parser:trim()
    local lines = self.lines._.lines
    for i = #lines, 1, -1 do
        if lines[i]:content() ~= "" then break end
        table.remove(lines, i)
    end
    self.lines._.lines = lines

    return self.lines
end

---@param str string
---@return lc.ui.Lines
function Parser.static:parse(str)
    local check_for_html = function()
        local parsers = require("nvim-treesitter.parsers")
        assert(parsers.get_parser_configs()["html"])
    end

    if pcall(check_for_html) then
        return Tag:parse(str)
    else
        return nil
    end
end

---@type fun(): lc.Parser
local LeetParser = Parser

return LeetParser
