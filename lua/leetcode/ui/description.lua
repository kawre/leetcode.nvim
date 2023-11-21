local config = require("leetcode.config")
local log = require("leetcode.logger")
local utils = require("leetcode.utils")

local img_ok, image_api = pcall(require, "image")
local img_sup = img_ok and config.user.image_support

local parser = require("leetcode.parser")
local t = require("leetcode.translator")

local Layout = require("leetcode-ui.layout")
local Text = require("leetcode-ui.component.text")
local padding = require("leetcode-ui.component.padding")

local NuiLine = require("nui.line")
local NuiSplit = require("nui.split")

---@class lc.ui.DescriptionSplit : NuiSplit
---@field split NuiSplit
---@field parent lc.ui.Question
---@field layout lc-ui.Layout
---@field visible boolean
---@field images table<string, Image>
local DescriptionSplit = NuiSplit:extend("LeetDescription")

local group_id = vim.api.nvim_create_augroup("leetcode_description", { clear = true })

function DescriptionSplit:autocmds()
    vim.api.nvim_create_autocmd("WinResized", {
        group = group_id,
        buffer = self.bufnr,
        callback = function() self:draw() end,
    })
end

function DescriptionSplit:unmount()
    DescriptionSplit.super.unmount(self)
    self = nil
end

function DescriptionSplit:mount()
    self.visible = true
    self:populate()
    DescriptionSplit.super.mount(self)

    local utils = require("leetcode-menu.utils")
    utils.set_buf_opts(self.bufnr, {
        modifiable = false,
        buflisted = false,
        matchpairs = "",
        swapfile = false,
        buftype = "nofile",
        filetype = "leetcode.nvim",
        synmaxcol = 0,
    })
    utils.set_win_opts(self.winid, {
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        wrap = not img_sup,
        colorcolumn = "",
        foldlevel = 999,
        foldcolumn = "1",
        cursorcolumn = false,
        cursorline = false,
        number = false,
        relativenumber = false,
        list = false,
        spell = false,
        signcolumn = "no",
    })
    if not img_ok and config.user.image_support then
        log.error("image.nvim not found but `image_support` is enabled")
    end

    self:draw()
    self:autocmds()
    return self
end

function DescriptionSplit:toggle()
    if self.visible then
        self:hide()
    else
        self:show()
    end

    self.visible = not self.visible
end

function DescriptionSplit:draw()
    self.layout:draw(self)
    self:draw_imgs()
end

function DescriptionSplit:draw_imgs()
    if not img_sup then return end

    local lines = vim.api.nvim_buf_get_lines(self.bufnr, 1, -1, false)
    for i, line in ipairs(lines) do
        for link in line:gmatch("->%((http[s]?://%S+)%)") do
            local img = self.images[link]

            if not img then
                self.images[link] = {}

                image_api.from_url(link, {
                    buffer = self.bufnr,
                    window = self.winid,
                    with_virtual_padding = true,
                }, function(image)
                    if not image then return end

                    self.images[link] = image
                    image:render({ y = i + 1 })
                end)
            elseif not vim.tbl_isempty(img) then
                img:clear(true)
            end
        end
    end
end

---@private
function DescriptionSplit:populate()
    local q = self.parent.q

    local linkline = NuiLine()
    linkline:append(self.parent.cache.link or "", "leetcode_alt")

    local titleline = NuiLine()
    titleline:append(q.frontend_id .. ". ", "leetcode_normal")

    titleline:append(utils.translate(q.title, q.translated_title))

    local statsline = NuiLine()
    statsline:append(
        t(q.difficulty),
        ({
            ["Easy"] = "leetcode_easy",
            ["Medium"] = "leetcode_medium",
            ["Hard"] = "leetcode_hard",
        })[q.difficulty]
    )
    statsline:append(" | ")

    statsline:append(q.likes .. " ", "leetcode_alt")
    if not config.is_cn then statsline:append(" " .. q.dislikes .. " ", "leetcode_alt") end
    statsline:append(" | ")

    statsline:append(
        ("%s %s %s"):format(q.stats.acRate, t("of"), q.stats.totalSubmission),
        "leetcode_alt"
    )
    if not vim.tbl_isempty(q.hints) then
        statsline:append(" | ")
        statsline:append("󰛨 " .. t("Hints"), "leetcode_hint")
    end

    local titlecomp = Text:init({ titleline }, { position = "center" })
    local statscomp = Text:init({ statsline }, { position = "center" })
    local linkcomp = Text:init({ linkline }, { position = "center" })

    local contents = parser:parse(utils.translate(q.content, q.translated_content))

    self.layout = Layout:init({
        linkcomp,
        padding:init(1),
        titlecomp,
        statscomp,
        padding:init(3),
        contents,
    })
end

---@param parent lc.ui.Question
function DescriptionSplit:init(parent)
    DescriptionSplit.super.init(self, {
        relative = "editor",
        position = config.user.description.position,
        size = config.user.description.width,
        enter = false,
        focusable = true,
    })

    self.parent = parent
    self.layout = {}
    self.visible = false
    self.images = {}
end

---@type fun(parent: lc.ui.Question): lc.ui.DescriptionSplit
local LeetDescription = DescriptionSplit

return LeetDescription
