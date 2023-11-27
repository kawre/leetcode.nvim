local Page = require("leetcode-ui.group.page")
local Pre = require("leetcode-ui.group.pre")
local Line = require("leetcode-ui.line")
local Group = require("leetcode-ui.group")
local Lines = require("leetcode-ui.lines")

local page = Page()

local group = Group({}, { spacing = 1 })

group:append("fasdfasdf")
group:append("fasdfasdf")
group:append("fasdfasdf")
group:append("fasdfasdf")
group:append("fasdfasdf")
group:append("fasdfasdf")
group:append("fasdfasdf")
group:append("fasdfasdf")
group:append("fasdfasdf")
group:append("fasdfasdf")
group:endl()
group:append("asdfasdf")
group:endgrp()

group:append("123123")
group:append("fasdf123123")
group:append("123123"):endl()
group:endgrp()

local title = Line():append("title")
local pre = Pre(title, group)

page:insert(pre)

local grp = Group({}, { position = "left", spacing = 2 })

grp:append("fasdf")
grp:append("fasdf")
grp:append("fasdf")
grp:append("fasdf")
grp:append("fasdf"):endl()
grp:append("fasdf")
grp:append("fasdf")

page:insert(grp)

local lines = Lines()

lines:append("fasdfaf")
lines:append("fasdfaf")
lines:append("fasdfaf"):endl()
lines:append("fasdfaf"):endl()
lines:append("fasdfaf"):endl()
lines:append("fasdfaf")
lines:append("fasdfaf"):endl():endl():endl():append("fasd")

page:insert(lines)

return page
