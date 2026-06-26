local Tag = require("leetcode-ui.group.tag")
local Line = require("leetcode-ui.line")
local Lines = require("leetcode-ui.lines")
local ui_utils = require("leetcode-ui.utils")

---@class lc.ui.Tag.table : lc.ui.Tag
---@field rows table[]
local Table = Tag:extend("LeetTagTable")

local function strwidth(text)
    return vim.api.nvim_strwidth(text or "")
end

local function trim(text)
    return (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function pad_right(text, width)
    return text .. (" "):rep(math.max(0, width - strwidth(text)))
end

local function wrap_text(text, width)
    text = text or ""
    if text == "" then
        return { "" }
    end

    width = math.max(width, 1)

    local wrapped, line, line_width = {}, "", 0
    local idx = 1
    while idx <= #text do
        local byte = text:byte(idx)
        local len = 1
        if byte >= 0xf0 then
            len = 4
        elseif byte >= 0xe0 then
            len = 3
        elseif byte >= 0xc0 then
            len = 2
        end

        local char = text:sub(idx, idx + len - 1)
        local char_width = strwidth(char)

        if line ~= "" and line_width + char_width > width then
            table.insert(wrapped, line)
            line = char
            line_width = char_width
        else
            line = line .. char
            line_width = line_width + char_width
        end

        idx = idx + len
    end

    table.insert(wrapped, line)
    return wrapped
end

local function line_texts(lines)
    local out = {}
    for _, line in ipairs(lines) do
        local text = trim(line:content())
        if text ~= "" then
            table.insert(out, text)
        end
    end
    return vim.tbl_isempty(out) and { "" } or out
end

function Table:tag_name(node)
    return self:get_el_data(node).tag
end

function Table:element_children(node)
    local children = {}
    for child in node:iter_children() do
        if child:type() == "element" then
            table.insert(children, child)
        end
    end
    return children
end

function Table:cell_texts(node)
    local cell = Tag(self.text, {}, node, self.tags)
    return line_texts(cell:lines())
end

function Table:parse_row(node)
    local cells = {}

    for _, child in ipairs(self:element_children(node)) do
        local tag = self:tag_name(child)
        if tag == "td" or tag == "th" then
            table.insert(cells, {
                header = tag == "th",
                texts = self:cell_texts(child),
            })
        end
    end

    return cells
end

function Table:collect_rows(node, rows)
    for _, child in ipairs(self:element_children(node)) do
        local tag = self:tag_name(child)

        if tag == "tr" then
            local row = self:parse_row(child)
            if not vim.tbl_isempty(row) then
                table.insert(rows, row)
            end
        else
            self:collect_rows(child, rows)
        end
    end
end

function Table:column_count()
    local cols = 0
    for _, row in ipairs(self.rows) do
        cols = math.max(cols, #row)
    end
    return cols
end

function Table:natural_widths(cols)
    local widths = {}
    for col = 1, cols do
        widths[col] = 1
    end

    for _, row in ipairs(self.rows) do
        for col, cell in ipairs(row) do
            for _, text in ipairs(cell.texts) do
                widths[col] = math.max(widths[col], strwidth(text))
            end
        end
    end

    return widths
end

function Table:fit_widths(widths, max_width)
    local cols = #widths
    local overhead = cols * 3 + 1
    local target = math.max(cols, max_width - overhead)

    local fitted, minimum = {}, {}
    for col, width in ipairs(widths) do
        fitted[col] = width
        minimum[col] = math.min(width, 6)
    end

    local function total()
        local sum = 0
        for _, width in ipairs(fitted) do
            sum = sum + width
        end
        return sum
    end

    while total() > target do
        local widest
        for col, width in ipairs(fitted) do
            if width > minimum[col] and (not widest or width > fitted[widest]) then
                widest = col
            end
        end

        if not widest then
            break
        end

        fitted[widest] = fitted[widest] - 1
    end

    return fitted
end

function Table:separator(widths)
    local parts = {}
    for _, width in ipairs(widths) do
        table.insert(parts, ("-"):rep(width + 2))
    end
    return "+" .. table.concat(parts, "+") .. "+"
end

function Table:render_row(row, widths, highlight)
    local cell_lines, height = {}, 1

    for col, width in ipairs(widths) do
        local cell = row[col] or { texts = { "" } }
        local wrapped = {}
        for _, text in ipairs(cell.texts) do
            vim.list_extend(wrapped, wrap_text(text, width))
        end
        cell_lines[col] = wrapped
        height = math.max(height, #wrapped)
    end

    local lines = {}
    for i = 1, height do
        local parts = {}
        for col, width in ipairs(widths) do
            table.insert(parts, " " .. pad_right(cell_lines[col][i] or "", width) .. " ")
        end

        local line = Line()
        line:append("|" .. table.concat(parts, "|") .. "|", highlight)
        table.insert(lines, line)
    end

    return lines
end

function Table:render_lines(max_width)
    if vim.tbl_isempty(self.rows) then
        return {}
    end

    local cols = self:column_count()
    local widths = self:fit_widths(self:natural_widths(cols), max_width or 80)
    local sep = self:separator(widths)
    local lines = {}

    local border = Line()
    border:append(sep, "leetcode_alt")
    table.insert(lines, border)

    for _, row in ipairs(self.rows) do
        local is_header = vim.tbl_contains(vim.tbl_map(function(cell)
            return cell.header
        end, row), true)

        vim.list_extend(lines, self:render_row(row, widths, is_header and "leetcode_normal" or "leetcode_alt"))

        local row_sep = Line()
        row_sep:append(sep, "leetcode_alt")
        table.insert(lines, row_sep)
    end

    return lines
end

function Table:contents()
    return { Lines(self:render_lines(80)) }
end

function Table:draw(layout, opts)
    local width = ui_utils.win_width(layout)
    local padding = (opts or {}).padding or {}

    if type(padding.left) == "number" then
        width = width - padding.left
    end

    Lines(self:render_lines(math.max(width - 1, 20))):draw(layout, opts)
end

function Table:init(text, opts, node, tags)
    Table.super.init(self, text, opts, node, tags)
    self.rows = {}
    self:collect_rows(node, self.rows)
    self:clear()
end

---@type fun(): lc.ui.Tag.table
local LeetTagTable = Table

return LeetTagTable
