-- @/leetcode-ui/group/tag/sup.lua
--
-- Renders <sup> tags.
--
local fn = require("leetcode-ui.utils").fn
local a = require("leetcode.api")

--- @class leetcode-ui.group.tag.sup
--- @field render fun(self: leetcode-ui.group.tag.sup, node: table): leetcode.lines
local Sup = {}
Sup.__index = Sup

--- @param node table
--- @return leetcode.lines
function Sup:render(node)
    local lines = require("leetcode-ui.lines")
    local l = lines.new()
    l:write("^")
    l:write(fn.reduce(node.children, function(acc, child)
        local success, res = pcall(self.render_child, self, child)
        if not success then
            return acc
        end
        return acc .. res
    end, ""))

    return l
end

--- @param opts leetcode-ui.opts
--- @return leetcode-ui.group.tag.sup
function Sup.new(opts)
    local obj = setmetatable({}, Sup)
    obj.opts = opts
    obj.render_child = require("leetcode-ui.group.init").render_child
    return obj
end

return Sup