local m = require("markup")
local cookie = require("leetcode.cache.cookie")
local Header = require("leetcode.ui.menu.header")
local Footer = require("leetcode.ui.menu.footer")
local Nav = require("leetcode.ui.menu.nav")
local config = require("leetcode.config")

local menu_ctx = m.hooks.context()
Leet.ctx.menu = menu_ctx

Leet.auth = m.hooks.store(function(set)
    return {
        auth = Markup.list(),
        set_auth = function(new_auth)
            set(function(state)
                state.auth = new_auth
            end)
        end,
        -- c = function(self, new_auth)
        --     self:set(function(state)
        --         state.auth = new_auth
        --     end)
        -- end,
    }
end)

local renderer = Markup.renderer({
    position = "current",
    hijack = true,
    show = false,
})

Leet.menu = renderer
Leet.auth:bind(renderer)

local App = m.component(function()
    local menu = m.hooks.use(Leet.ctx.menu)

    m.hooks.effect(function()
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
        -- padding = { 1, 2 },
        Header(),
        Nav(),
        Footer(),
    })
end)

local Root = m.component(function()
    local page, set_page = m.hooks.variable("loading")
    local user, set_user = m.hooks.variable({})

    return Leet.ctx.menu:provider({
        value = {
            page = page,
            set_page = set_page,
            user = user,
            set_user = set_user,
        },
        App(),
    })
end)

renderer:bind(Root)

return renderer
