local html = require("leetcode.parser.html")
local plain = require("leetcode.parser.plain")
local log = require("leetcode.logger")

---@class lc.Parser
local Parser = {}

---@class lc.Parser.Tag
---@field tag string
---@field attrs lc.Parser.Tag.Attr[]
--
---@class lc.Parser.Tag.Attr
---@field name string
---@field value string

---@param str string
---@return lc-ui.Text
function Parser:parse(str)
    local check_for_html = function()
        local parsers = require("nvim-treesitter.parsers")
        assert(parsers.get_parser_configs()["html"])
    end

    if pcall(check_for_html) then
        return html:parse(str)
    else
        return plain:parse(str)
    end
end

return Parser
