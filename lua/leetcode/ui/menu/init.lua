local m = require("markup")
local cookie = require("leetcode.cache.cookie")
local Header = require("leetcode.ui.menu.header")
local Footer = require("leetcode.ui.menu.footer")
local Nav = require("leetcode.ui.menu.nav")

local menu_ctx = m.context()
Leet.ctx.menu = menu_ctx

local renderer = Markup.renderer({
    position = "right",
    relative = "editor",

    show = false,
    width = 150,
})

local App = m.Component(function()
    local menu = m.use(Leet.ctx.menu)

    m.effect(function()
        if cookie.get() then
            menu.set_page("loading")

            local auth_api = require("leetcode.api.auth")
            auth_api.user(function(_, err)
                if err then
                    menu.set_page("signin")
                    Markup.log.error(err)
                else
                    menu.set_page("menu")
                end
            end)
        else
            menu.set_page("signin")
        end
    end, {})

    return m.vflex({
        align = "center",
        spacing = 2,
        width = 100,
        -- padding = { 1, 2 },
        Header(),
        Nav(),
        Footer(),
    })
end)

local Root = m.Component(function()
    local page, set_page = m.variable("loading")

    return Leet.ctx.menu.provider({
        value = {
            page = page,
            set_page = set_page,
        },
        App(),
    })
end)

renderer:bind(Root)

return renderer
