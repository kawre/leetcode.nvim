local theme = require("leetcode.theme")

local Group = require("leetcode-ui.group")

local log = require("leetcode.logger")

---@class lc.ui.Tag : lc.ui.Group
---@field tags string[]
local Tag = Group:extend("LeetTag")

---@param opts lc.ui.opts
---@param tags string[]
---@param node TSNode
function Tag:init(opts, tags, node) --
    Tag.super.init(self, {}, opts or {})

    self.node = node
    self.tags = tags
end

function Tag:endl()
    -- local c = self:contents()

    -- local lines = Lines.contents(self)
    --
    -- local tbl = {}
    -- for i, line in ipairs(lines) do
    --     tbl[i .. ""] = line:content()
    -- end
    -- log.debug(tbl)

    -- if c[#c] then --
    --     -- if #l < 2 or (l[#l]._content == "" and l[#l - 1].content == "") then --
    --     -- end
    -- end

    Tag.super.endl(self)
end

---@type fun(opts: lc.ui.opts, tags: string[], node?: TSNode): lc.ui.Tag
local LeetTag = Tag

local function req_tag(str) return require("leetcode-ui.group.tag." .. str) end

---@param tags string[]
---@param node TSNode
function Tag.static:from(tags, node)
    local t = {
        pre = req_tag("pre"),
        ul = req_tag("ul"),
        ol = req_tag("ol"),
    }

    return (t[tags[#tags]] or LeetTag)({ hl = theme.get_dynamic(tags) }, vim.deepcopy(tags), node)
end

return LeetTag
