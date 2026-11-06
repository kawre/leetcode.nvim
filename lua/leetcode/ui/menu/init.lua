local m = require("markup")
local cookie = require("leetcode.cache.cookie")
local Header = require("leetcode.ui.menu.header")
local Footer = require("leetcode.ui.menu.footer")
local Nav = require("leetcode.ui.menu.nav")
local config = require("leetcode.config")

---@class leet.menu
local M = {
    page = m.signal("loading"),
    win = Markup.window({
        position = "current",
        hijack = true,
        show = false,
    }),
}

Leet.menu = M

---@param page string
function M.set_page(page)
    M.page(page)
end

local function sign_in()
    if not cookie.get() then
        return M.set_page("signin")
    end

    M.set_page("loading")

    require("leetcode.api.auth").user(function(_, err)
        if err then
            M.set_page("signin")
            Markup.log.error(err)
        else
            M.set_page("menu")
        end
    end)
end

local App = m.component(function()
    local view = m.use_view()

    m.use_key("<CR>", function()
        view:press()
    end)

    sign_in()

    return m.vflex({
        align = "center",
        spacing = 2,
        Header(),
        Nav(),
        Footer(),
    })
end)

function M.render()
    M.view = M.view or Markup.view(M.win, { snap = true })
    M.view:render(App())
end

return M
