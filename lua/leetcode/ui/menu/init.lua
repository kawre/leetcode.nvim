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

-- local mt = getmetatable(Menu)
-- local old_index = mt.__index
-- mt.__index = function(self, key)
--     if key == "winid" then
--         return self.id
--     end
--
--     return old_index[key]
-- end
-- setmetatable(Menu, mt)

function Menu:init()
    Menu.super.init(self, { id = 0, bufnr = 0 })

    _Lc_state.menu = self
end

function Menu:set_page(page)
    self.page = page
    self:draw()
end

function Menu:render()
    local menu = markup.Component(function(props)
        return markup.Flex({
            margin = { top = 3 },
            align = "center",
            spacing = 3,
            Header(),
            Nav({ page = self.page }),
            Footer(),
        })
    end)

    Menu.super.render(self, menu())
end

function Menu:remount() end

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
