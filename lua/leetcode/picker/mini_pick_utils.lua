local M = {}

---@class MiniPickItem
---@field entry (string|string[])[]

---Render items to be shown in the `mini.pick` picker menu
---@param buf_id integer Buffer associated with the `mini.pick` picker
---@param ns_id integer Namespace associated with the `mini.pick` picker
---@param items MiniPickItem[] Items to be rendered into the picker menu
M.show_items = function(buf_id, ns_id, items)
    local lines, highlights = {}, {}

    for _, item in ipairs(items) do
        local line, col = {}, 0
        local hl_spans = {}

        for _, part in ipairs(item.entry) do
            if type(part) == "string" then
                part = { part }
            end
            local text, hl = part[1], part[2]
            table.insert(line, text)

            local start_col, end_col = col, col + #text
            if hl then
                table.insert(hl_spans, { hl = hl, start_col = start_col, end_col = end_col })
            end

            col = end_col + 1 -- account for space
            table.insert(line, " ")
        end

        table.insert(lines, table.concat(line))
        table.insert(highlights, hl_spans)
    end

    -- Set lines
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
    vim.api.nvim_buf_clear_namespace(buf_id, ns_id, 0, -1)

    -- Apply highlights on each line chunk
    local opts = { hl_mode = "combine", priority = 200 }
    for row, hl_spans in ipairs(highlights) do
        for _, span in ipairs(hl_spans) do
            opts.hl_group = span.hl
            opts.end_row, opts.end_col = row - 1, span.end_col
            vim.api.nvim_buf_set_extmark(buf_id, ns_id, row - 1, span.start_col, opts)
        end
    end
end

return M
