local Tag = require("leetcode-ui.group.tag")

local log = require("leetcode.logger")

---@class lc.ui.Tag.a : lc.ui.Tag
local A = Tag:extend("LeetTagA")

---@param url string
local function norm_url(url)
    return url:lower():gsub("/$", ""):gsub("#.-$", "")
end

---@param u1 string
---@param u2 string
local function is_same_url(u1, u2)
    return norm_url(u1) == norm_url(u2)
end

function A:contents()
    local Group = require("leetcode-ui.group")
    local grp = Group()

    if is_same_url(self:content(), self.data.attrs.href) then
        grp:append(self:content():gsub("：", ":"), "leetcode_link")
        return grp:contents()
    else
        local link = (self.data.attrs.href or ""):gsub("：", ":")

        grp:append("[", "leetcode_alt")
        grp:append(self:content(), "leetcode_ref")
        grp:append("]", "leetcode_alt")
        grp:append("(", "leetcode_alt")
        grp:append(link, "leetcode_link")
        grp:append(")", "leetcode_alt")

        return grp:contents()
    end
end

---@type fun(): lc.ui.Tag.pre
local LeetTagA = A

return LeetTagA
