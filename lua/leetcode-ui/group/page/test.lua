local Page = require("leetcode-ui.group.page")
local Pre = require("leetcode-ui.group.pre")
local Line = require("leetcode-ui.line")
local Group = require("leetcode-ui.group")
local Lines = require("leetcode-ui.lines")

local page = Page()

local lines = Lines()

lines:append("fasdfaf")
lines:append("fasdfaf")
-- lines:append("fasdfaf"):endl()
-- lines:append("fasdfaf"):endl()
-- lines:append("fasdfaf"):endl()
-- lines:append("fasdfaf")
-- lines:append("fasdfaf"):endl():endl():endl():append("fasd")

local pre = Pre(Line():append("lol"), lines)

page:insert(pre)

return page
