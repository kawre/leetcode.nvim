local Tag = require("leetcode-ui.group.tag")
local Line = require("leetcode-ui.line")
local Lines = require("leetcode-ui.lines")

local ts = vim.treesitter

---@class lc.ui.Tag.table : lc.ui.Tag
local Table = Tag:extend("LeetTagTable")

local border = {
    tl = "┌", tr = "┐", bl = "└", br = "┘",
    h  = "─", v  = "│",
    th = "┬", bh = "┴",
    lv = "├", rv = "┤", cross = "┼",
}

---Recursively extract plain text from a TSNode, skipping tag markup
---@param node TSNode
---@param src string
---@return string
local function extract_text(node, src)
    local ntype = node:type()
    if ntype == "start_tag" or ntype == "end_tag" or ntype == "self_closing_tag" then
        return ""
    elseif ntype == "text" then
        return (ts.get_node_text(node, src):gsub("&nbsp;", " "))
    elseif ntype == "entity" then
        local e = ts.get_node_text(node, src)
        if e == "&nbsp;" then
            return " "
        elseif e == "&lcnl;" or e == "&lctab;" then
            return " "
        else
            return ""
        end
    end

    local parts = {}
    for child in node:iter_children() do
        table.insert(parts, extract_text(child, src))
    end
    return table.concat(parts)
end

---Get the tag name of an element node
---@param node TSNode
---@param src string
---@return string|nil
local function get_tag_name(node, src)
    if node:type() ~= "element" then return nil end
    for child in node:iter_children() do
        local ct = child:type()
        if ct == "start_tag" or ct == "self_closing_tag" then
            for c in child:iter_children() do
                if c:type() == "tag_name" then
                    return ts.get_node_text(c, src)
                end
            end
        end
    end
    return nil
end

---Parse a <tr> node into a list of cells
---@param tr_node TSNode
---@param src string
---@param is_header_row boolean
---@return { text: string, is_header: boolean }[]
local function parse_row(tr_node, src, is_header_row)
    local cells = {}
    for child in tr_node:iter_children() do
        if child:type() == "element" then
            local tag = get_tag_name(child, src)
            if tag == "th" or tag == "td" then
                local raw = extract_text(child, src)
                local text = raw:match("^%s*(.-)%s*$") or ""
                table.insert(cells, {
                    text = text,
                    is_header = is_header_row or tag == "th",
                })
            end
        end
    end
    return cells
end

---Parse the full table node into rows
---@param node TSNode
---@param src string
---@return { cells: { text: string, is_header: boolean }[], is_header: boolean }[]
local function parse_table(node, src)
    local rows = {}

    local function parse_section(section_node, is_header)
        for child in section_node:iter_children() do
            if child:type() == "element" and get_tag_name(child, src) == "tr" then
                local cells = parse_row(child, src, is_header)
                if #cells > 0 then
                    table.insert(rows, { cells = cells, is_header = is_header })
                end
            end
        end
    end

    for child in node:iter_children() do
        if child:type() == "element" then
            local tag = get_tag_name(child, src)
            if tag == "thead" then
                parse_section(child, true)
            elseif tag == "tbody" or tag == "tfoot" then
                parse_section(child, false)
            elseif tag == "tr" then
                local cells = parse_row(child, src, false)
                if #cells > 0 then
                    table.insert(rows, { cells = cells, is_header = false })
                end
            end
        end
    end

    return rows
end

function Table:contents()
    local rows = self._rows
    if not rows or #rows == 0 then return {} end

    local ncols = 0
    for _, row in ipairs(rows) do
        ncols = math.max(ncols, #row.cells)
    end

    -- Calculate minimum column widths from content
    local col_widths = {}
    for i = 1, ncols do
        col_widths[i] = 1
    end
    for _, row in ipairs(rows) do
        for i, cell in ipairs(row.cells) do
            col_widths[i] = math.max(col_widths[i], vim.api.nvim_strwidth(cell.text))
        end
    end
    -- Add 2 for padding (one space each side)
    for i = 1, ncols do
        col_widths[i] = col_widths[i] + 2
    end

    local hl_border = "leetcode_alt"
    local hl_header = "leetcode_ref"
    local hl_cell   = "leetcode_normal"

    local function make_hsep(left, mid, right)
        local line = Line()
        line:append(left, hl_border)
        for i = 1, ncols do
            line:append(border.h:rep(col_widths[i]), hl_border)
            line:append(i < ncols and mid or right, hl_border)
        end
        return line
    end

    local function make_row_line(row)
        local line = Line()
        line:append(border.v, hl_border)
        for i = 1, ncols do
            local cell = row.cells[i]
            local text = cell and cell.text or ""
            local pad_right = col_widths[i] - vim.api.nvim_strwidth(text) - 1
            line:append(" " .. text .. (" "):rep(pad_right), cell and cell.is_header and hl_header or hl_cell)
            line:append(border.v, hl_border)
        end
        return line
    end

    local result = {}
    table.insert(result, make_hsep(border.tl, border.th, border.tr))

    for idx, row in ipairs(rows) do
        table.insert(result, make_row_line(row))
        local next_row = rows[idx + 1]
        if row.is_header and (not next_row or not next_row.is_header) then
            table.insert(result, make_hsep(border.lv, border.cross, border.rv))
        end
    end

    table.insert(result, make_hsep(border.bl, border.bh, border.br))

    return { Lines(result) }
end

function Table:init(text, opts, node, tags)
    self.text = text
    self.node = node
    self.tags = tags
    self.data = self:get_el_data(node)
    self.name = self.data.tag

    local utils = require("leetcode.parser.utils")
    opts = vim.tbl_extend("force", { hl = utils.hl(self) }, opts or {})
    Tag.super.init(self, {}, opts)

    self._rows = parse_table(node, text)
end

---@type fun(): lc.ui.Tag.table
local LeetTagTable = Table

return LeetTagTable
