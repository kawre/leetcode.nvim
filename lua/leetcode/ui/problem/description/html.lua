--- Renders LeetCode's problem HTML as markup elements.
---
--- Text only needs to be split into blocks here. Wrapping belongs to the blocks,
--- so a resize never has to parse anything again.

local m = require("markup")
local config = require("leetcode.config")
local theme = require("leetcode.theme")
local Normalizer = require("leetcode.parser.normalizer")
local entities = require("leetcode.parser.utils")

local ts = vim.treesitter

---@class leet.ui.html
local M = {}

local border = {
	tl = "┌", tr = "┐", bl = "└", br = "┘",
	h = "─", v = "│",
	th = "┬", bh = "┴",
	lv = "├", rv = "┤", cross = "┼",
}

--- Collects spans into lines, and lines into a list of blocks.
---@class leet.ui.html.builder
---@field items table[]
---@field spans { text: string, hl: string }[]
local Builder = {}
Builder.__index = Builder

local function builder()
	return setmetatable({ items = {}, spans = {} }, Builder)
end

function Builder:push(text, hl)
	if text == "" then
		return
	end
	local last = self.spans[#self.spans]
	if last and last.hl == hl then
		last.text = last.text .. text
	else
		self.spans[#self.spans + 1] = { text = text, hl = hl }
	end
end

--- Ends the current line, dropping it when it is only blanks.
function Builder:line()
	local spans = self.spans
	self.spans = {}

	for _, span in ipairs(spans) do
		if span.text:find("%S") then
			self.items[#self.items + 1] = { spans = spans }
			return
		end
	end
end

function Builder:gap()
	self:line()
	local last = self.items[#self.items]
	if last and not last.gap then
		self.items[#self.items + 1] = { gap = true }
	end
end

function Builder:element(element)
	self:line()
	self.items[#self.items + 1] = { element = element }
end

--- Blocks without blank lines at the ends. `prefix` starts every line.
---@param prefix? { text: string, hl: string }
function Builder:finish(prefix)
	self:line()

	while #self.items > 0 and self.items[#self.items].gap do
		table.remove(self.items)
	end

	return vim.tbl_map(function(item)
		if item.gap then
			return m.newl()
		elseif item.element then
			return item.element
		end

		local spans = {}
		if prefix then
			spans[1] = m.inline(prefix.text, prefix.hl)
		end
		for _, span in ipairs(item.spans) do
			spans[#spans + 1] = m.inline(span.text, span.hl)
		end
		return m.block(spans)
	end, self.items)
end

---@class leet.ui.html.context
---@field source string
---@field tags string[] open tags, which decide the highlight

local function get_text(node, ctx)
	return ts.get_node_text(node, ctx.source)
end

--- Tag name and attributes of an element.
local function element_data(node, ctx)
	for child in node:iter_children() do
		local kind = child:type()
		if kind == "start_tag" or kind == "self_closing_tag" then
			local tag, attrs = nil, {}
			for part in child:iter_children() do
				local part_kind = part:type()
				if part_kind == "tag_name" then
					tag = get_text(part, ctx)
				elseif part_kind == "attribute" then
					local name, value
					for piece in part:iter_children() do
						if piece:type() == "attribute_name" then
							name = get_text(piece, ctx)
						elseif piece:type() == "quoted_attribute_value" then
							value = get_text(piece, ctx):gsub("\"", "")
						end
					end
					if name then
						attrs[name] = value
					end
				end
			end
			return tag, attrs
		end
	end
	return nil, {}
end

local function entity_text(text)
	local value = entities.entity(text)
	return (value:gsub("\t", "    "))
end

--- Plain text of a node, for links and table cells.
local function text_of(node, ctx)
	local kind = node:type()
	if kind == "start_tag" or kind == "end_tag" or kind == "self_closing_tag" then
		return ""
	elseif kind == "text" then
		return get_text(node, ctx)
	elseif kind == "entity" then
		local text = get_text(node, ctx)
		if text == "&lcnl;" or text == "&lcpad;" or text == "&lctab;" then
			return " "
		end
		return entity_text(text)
	end

	local parts = {}
	for child in node:iter_children() do
		parts[#parts + 1] = text_of(child, ctx)
	end
	return table.concat(parts)
end

local function highlight(ctx)
	return theme.get_dynamic(ctx.tags)
end

local walk

---@param url string
local function norm_url(url)
	return url:lower():gsub("/$", ""):gsub("#.-$", "")
end

local function render_link(b, node, attrs, ctx)
	local text = text_of(node, ctx)
	local href = attrs.href or ""

	if norm_url(text) == norm_url(href) then
		b:push((text:gsub("：", ":")), "leetcode_link")
		return
	end

	b:push("[", "leetcode_alt")
	b:push(text, "leetcode_ref")
	b:push("]", "leetcode_alt")
	b:push("(", "leetcode_alt")
	b:push((href:gsub("：", ":")), "leetcode_link")
	b:push(")", "leetcode_alt")
end

local function render_image(b, attrs)
	local alt = attrs.alt
	b:push("[", "leetcode_alt")
	b:push((alt and alt ~= "") and alt or "img", "leetcode_ref")
	b:push("]", "leetcode_alt")
	b:push("(", "leetcode_alt")
	b:push(((attrs.src or ""):gsub("：", ":")), "leetcode_link")
	b:push(")", "leetcode_alt")
end

--- Marker in its own column, so wrapped text keeps a hanging indent.
local function render_list(b, node, tag, ctx)
	local items = {}
	local order = 1

	for child in node:iter_children() do
		if child:type() == "element" and element_data(child, ctx) == "li" then
			local marker = tag == "ol" and (order .. ". ") or "* "
			order = order + 1

			local content = builder()
			walk(child, ctx, content)

			items[#items + 1] = m.flex({
				m.inline({ marker, style = "leetcode_list", shrink = 0 }),
				m.block({ grow = 1, content:finish() }),
			})
		end
	end

	b:element(m.block({ padding_left = 2, items }))
end

local function render_pre(b, node, ctx)
	local content = builder()
	walk(node, ctx, content)
	b:element(m.block(content:finish({ text = config.icons.indent, hl = "leetcode_indent" })))
end

local function table_rows(node, ctx)
	local rows = {}

	local function add_row(tr, is_header)
		local cells = {}
		for child in tr:iter_children() do
			if child:type() == "element" then
				local tag = element_data(child, ctx)
				if tag == "th" or tag == "td" then
					cells[#cells + 1] = {
						text = vim.trim(text_of(child, ctx)),
						is_header = is_header or tag == "th",
					}
				end
			end
		end
		if #cells > 0 then
			rows[#rows + 1] = { cells = cells, is_header = is_header }
		end
	end

	for child in node:iter_children() do
		if child:type() == "element" then
			local tag = element_data(child, ctx)
			if tag == "tr" then
				add_row(child, false)
			elseif tag == "thead" or tag == "tbody" or tag == "tfoot" then
				for row in child:iter_children() do
					if row:type() == "element" and element_data(row, ctx) == "tr" then
						add_row(row, tag == "thead")
					end
				end
			end
		end
	end

	return rows
end

local function render_table(b, node, ctx)
	local rows = table_rows(node, ctx)
	if #rows == 0 then
		return
	end

	local columns = 0
	for _, row in ipairs(rows) do
		columns = math.max(columns, #row.cells)
	end

	local widths = {}
	for i = 1, columns do
		widths[i] = 1
	end
	for _, row in ipairs(rows) do
		for i, cell in ipairs(row.cells) do
			widths[i] = math.max(widths[i], vim.api.nvim_strwidth(cell.text))
		end
	end

	local hl_border, hl_header, hl_cell = "leetcode_alt", "leetcode_ref", "leetcode_normal"

	local function separator(left, middle, right)
		local parts = { left }
		for i = 1, columns do
			parts[#parts + 1] = border.h:rep(widths[i] + 2)
			parts[#parts + 1] = i < columns and middle or right
		end
		return m.block(table.concat(parts), hl_border)
	end

	local function row_line(row)
		local spans = { m.inline(border.v, hl_border) }
		for i = 1, columns do
			local cell = row.cells[i]
			local text = cell and cell.text or ""
			local padding = (" "):rep(widths[i] - vim.api.nvim_strwidth(text) + 1)
			spans[#spans + 1] = m.inline(" " .. text .. padding, cell and cell.is_header and hl_header or hl_cell)
			spans[#spans + 1] = m.inline(border.v, hl_border)
		end
		return m.block(spans)
	end

	local lines = { separator(border.tl, border.th, border.tr) }
	for index, row in ipairs(rows) do
		lines[#lines + 1] = row_line(row)
		local next_row = rows[index + 1]
		if row.is_header and (not next_row or not next_row.is_header) then
			lines[#lines + 1] = separator(border.lv, border.cross, border.rv)
		end
	end
	lines[#lines + 1] = separator(border.bl, border.bh, border.br)

	b:element(m.block({ white_space = "nowrap", lines }))
end

local function render_element(b, node, ctx)
	local tag, attrs = element_data(node, ctx)

	if tag == "a" then
		return render_link(b, node, attrs, ctx)
	elseif tag == "img" then
		return render_image(b, attrs)
	end

	ctx.tags[#ctx.tags + 1] = tag

	if tag == "ul" or tag == "ol" then
		render_list(b, node, tag, ctx)
	elseif tag == "pre" or tag == "blockquote" then
		render_pre(b, node, ctx)
	elseif tag == "table" then
		render_table(b, node, ctx)
	elseif tag == "sub" or tag == "sup" then
		b:push(tag == "sub" and "_" or "^", highlight(ctx))
		walk(node, ctx, b)
	elseif tag == "p" or tag == "div" then
		b:line()
		walk(node, ctx, b)
		b:line()
	else
		walk(node, ctx, b)
	end

	ctx.tags[#ctx.tags] = nil
end

---@param node TSNode
---@param ctx leet.ui.html.context
---@param b leet.ui.html.builder
walk = function(node, ctx, b)
	for child in node:iter_children() do
		local kind = child:type()

		if kind == "text" or kind == "ERROR" then
			b:push(get_text(child, ctx), highlight(ctx))
		elseif kind == "element" then
			render_element(b, child, ctx)
		elseif kind == "entity" then
			local text = get_text(child, ctx)
			if text == "&lcnl;" then
				b:line()
			elseif text == "&lcpad;" then
				b:gap()
			else
				b:push(entity_text(text), highlight(ctx))
			end
		end
	end
end

--- Without the html parser, the text is still worth showing.
local function plain(text)
	local lines = {}
	for line in vim.gsplit(text:gsub("<[^>]+>", ""), "\n") do
		line = line:gsub("&[%a%d#]+;", entities.entity)
		lines[#lines + 1] = m.block(line ~= "" and line or " ", "leetcode_normal")
	end
	return m.block(lines)
end

---@param text string html
---@return markup.element
function M.parse(text)
	local normalized = Normalizer:norm(text)

	local ok, parser = pcall(ts.get_string_parser, normalized, "html")
	if not ok then
		return plain(text)
	end

	local b = builder()
	walk(parser:parse()[1]:root(), { source = normalized, tags = {} }, b)
	return m.block(b:finish())
end

return M
