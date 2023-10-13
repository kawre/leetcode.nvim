local log = require("leetcode.logger")
local NuiPopup = require("nui.popup")
local NuiText = require("nui.text")
local NuiLine = require("nui.line")

---@class lc.Hints
---@field popup NuiPopup
---@field parent lc.Question
---@field hints table[]
local Hints = {}
Hints.__index = Hints

function Hints:mount()
    log.debug(self)
    self.popup:mount()
    local utils = require("leetcode-menu.utils")
    utils.apply_opt_local({ wrap = true })

    local NuiTree = require("nui.tree")

    local nodes = {}
    for i, hint in ipairs(self.hints) do
        local node = NuiTree.Node(
            { text = NuiText("󰛨 Hint " .. i, "LeetCodeHint") },
            { NuiTree.Node({ text = hint }) }
        )

        table.insert(nodes, node)
    end
    if vim.tbl_isempty(nodes) then
        table.insert(nodes, NuiTree.Node({ text = NuiText("No hints available", "LeetCodeError") }))
    end

    local tree = NuiTree({
        bufnr = self.popup.bufnr,
        nodes = nodes,
        prepare_node = function(node)
            local line = NuiLine()

            line:append(string.rep("  ", node:get_depth() - 1))

            if node:has_children() then
                line:append(node:is_expanded() and " " or " ", "SpecialChar")
                line:append(node.text)
            else
                line:append("  ")
                local parser = require("leetcode.parser")
                local txt = parser:init(node.text, "html"):parse()
                if txt.lines[1] then line:append(txt.lines[1]) end
            end

            return line
        end,
    })

    local opts = { noremap = true, nowait = true }
    self.popup:map("n", { "<Esc>", "q" }, function() self.popup:hide() end, opts)

    self.popup:map("n", "<CR>", function()
        local node = tree:get_node()
        if not node then return end

        if not node:is_expanded() then
            node:expand()
        else
            node:collapse()
        end

        tree:render()
    end, opts)

    tree:render()
    return self
end

function Hints:show()
    if self.popup._.mounted then
        self.popup:show()
    else
        self:mount()
    end
end

function Hints:hide() self.popup:hide() end

-- function Hints:toggle()
--
-- end

---@param parent lc.Question
function Hints:init(parent)
    log.debug(parent.q.hints)

    local popup = NuiPopup({
        position = "50%",
        size = {
            width = 80,
            height = 40,
        },
        enter = true,
        focusable = true,
        zindex = 50,
        relative = "editor",
        border = {
            padding = {
                top = 2,
                bottom = 2,
                left = 3,
                right = 3,
            },
            style = "rounded",
            text = {
                top = " Question Hints ",
            },
        },
        buf_options = {
            modifiable = false,
            readonly = false,
        },
        win_options = {
            winhighlight = "Normal:NormalSB,FloatBorder:FloatBorder",
        },
    })

    local obj = setmetatable({
        popup = popup,
        hints = parent.q.hints,
        parent = parent,
    }, self)

    return obj
end

return Hints
