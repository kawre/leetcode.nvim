local markup = require("markup")
local log = require("leetcode.logger")
local cookie = require("leetcode.cache.cookie")
local Header = require("leetcode.ui.menu.header")
local Footer = require("leetcode.ui.menu.footer")
local Nav = require("leetcode.ui.menu.nav")

---@class lc.ui.Menu2.props : markup.Renderer.props

---@class lc.ui.Menu2 : markup.Renderer
---@field protected _ lc.ui.Menu2.props
---@field protected super markup.Renderer
---@field body lc.ui.menu.Page
local Menu = markup.Renderer:extend("leet.menu")

function Menu:init()
    Menu.super.init(self, { winid = 0, bufnr = 0 })

    _Lc_state.menu = self
end

function Menu:set_page(page)
    self.page = page
    self:draw()
end

function Menu:render()
    self:set_body({
        markup.Flex({
            margin = { top = 3 },
            align = "center",
            spacing = 3,
            children = {
                Header(),
                Nav({ page = self.page }),
                Footer(),
            },
        }),
    })

    Menu.super.render(self)
end

function Menu:draw()
    self:render()
end

function Menu:mount()
    if cookie.get() then
        self:set_page("loading")

        local auth_api = require("leetcode.api.auth")
        auth_api.user(function(_, err)
            if err then
                self:set_page("signin")
                log.err(err)
            else
                local cmd = require("leetcode.command")
                cmd.start_user_session()
            end
        end)
    else
        self:set_page("signin")
    end
end

return Menu
