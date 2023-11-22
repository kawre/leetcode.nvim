local NuiPopup = require("nui.popup")
local Renderer = require("leetcode-ui.renderer")

local log = require("leetcode.logger")

---@class lc-ui.Popup : NuiPopup
---@field visible boolean
---@field renderer lc-ui.Renderer
local Popup = NuiPopup:extend("LeetPopup")

function Popup:focus()
    if not vim.api.nvim_win_is_valid(self.winid) then return end
    vim.api.nvim_set_current_win(self.winid)
end

function Popup:show()
    if not self._.mounted then
        self:mount()
    elseif not self.visible then
        Popup.super.show(self)
    end

    self.visible = true
end

function Popup:unmount()
    Popup.super.unmount(self)

    self.renderer.bufnr = nil
    self.renderer.winid = nil

    self.visible = false
end

function Popup:_buf_create()
    Popup.super._buf_create(self)
    self.renderer.bufnr = self.bufnr
end

function Popup:_buf_destory()
    Popup.super._buf_destory(self)
    -- log.info({
    --     event = "buf_destroy",
    --     name = self.class.name,
    --     bufnr = self.bufnr,
    --     winid = self.winid,
    -- })
    self.renderer.bufnr = nil
end

function Popup:mount()
    Popup.super.mount(self)

    self.renderer.bufnr = self.bufnr
    self.renderer.winid = self.winid

    self.visible = true
end

function Popup:hide()
    if not self.visible then return end
    Popup.super.hide(self)
    self.visible = false
end

function Popup:toggle()
    if self.visible then
        self:hide()
    else
        self:show()
    end
end

function Popup:handle_leave() self:hide() end

function Popup:init(opts)
    local options = vim.tbl_deep_extend("force", {
        focusable = true,
        border = {
            padding = {
                top = 1,
                bottom = 1,
                left = 3,
                right = 3,
            },
            style = "rounded",
        },
    }, opts or {})

    self.renderer = self.renderer or Renderer()
    self.visible = false

    Popup.super.init(self, options)

    self:on("BufUnload", function() --
        log.error("Do not close `leetcode.nvim` popups. Use `q` or `Esc` instead")
    end)
    self:on({ "BufLeave", "WinLeave" }, function() self:handle_leave() end)
    self:map("n", { "q", "<Esc>" }, function() self:hide() end)
end

---@type fun(opts: table): lc-ui.Popup
local LeetPopup = Popup

return LeetPopup
