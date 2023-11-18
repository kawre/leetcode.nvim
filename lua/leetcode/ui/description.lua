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
local Split = require("nui.split")

---@class lc.Description
---@field split NuiSplit
---@field parent lc.Question
---@field layout lc-ui.Layout
---@field visible boolean
---@field images table<string, Image>
local description = {}
description.__index = description

local group_id = vim.api.nvim_create_augroup("leetcode_description", { clear = true })

function description:autocmds()
    vim.api.nvim_create_autocmd("WinResized", {
        group = group_id,
        buffer = self.split.bufnr,
        callback = function() self:draw() end,
    })
end

function description:mount()
    self.visible = true
    self:populate()
    self.split:mount()

    local utils = require("leetcode-menu.utils")
    utils.set_buf_opts(self.split.bufnr, {
        modifiable = false,
        buflisted = false,
        matchpairs = "",
        swapfile = false,
        buftype = "nofile",
        filetype = "leetcode.nvim",
        synmaxcol = 0,
    })
    utils.set_win_opts(self.split.winid, {
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

function description:toggle()
    if self.visible then
        self.split:hide()
    else
        self.split:show()
    end

    self.visible = not self.visible
end

function description:draw()
    self.layout:draw(self.split)
    self:draw_imgs()
end

function description:draw_imgs()
    if not img_sup then return end

    local lines = vim.api.nvim_buf_get_lines(self.split.bufnr, 1, -1, false)
    for i, line in ipairs(lines) do
        for link in line:gmatch("->%((http[s]?://%S+)%)") do
            local img = self.images[link]

            if not img then
                self.images[link] = {}

                image_api.from_url(link, {
                    buffer = self.split.bufnr,
                    window = self.split.winid,
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
function description:populate()
    local q = self.parent.q

    local linkline = NuiLine()
    linkline:append(self.parent.cache.link, "leetcode_alt")

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

---@param parent lc.Question
function description:init(parent)
    local split = Split({
        relative = "editor",
        position = config.user.description.position,
        size = config.user.description.width,
        enter = false,
        focusable = true,
    })

    self = setmetatable({
        split = split,
        parent = parent,
        layout = {},
        visible = false,
        images = {},
    }, self)

    return self:mount()
end

return description
