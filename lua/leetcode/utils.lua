---@class lc.Utils
local utils = {}

function utils.remove_cookie()
    require("leetcode.cache.cookie").delete()
    -- require("leetcode.ui.dashboard").apply("default")
end

function utils.alpha_move_cursor_top()
    local curr_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_cursor(curr_win, { 1, 0 })
    require("alpha").move_cursor(curr_win)
end

---Extracts an HTML tag from a string.
---
---@param str string The input string containing HTML tags.
---@return string | nil The extracted HTML tag, or nil if no tag is found.
function utils.get_html_tag(str) return str:match("^<(.-)>") end

---@param str string
---@param tag string
---
---@return string
function utils.strip_html_tag(str, tag)
    local regex = string.format("^<%s>(.*)</%s>$", tag, tag)
    assert(str:match(regex))

    local offset = 3 + tag:len()
    return str:sub(offset, str:len() - offset)
end

---@param fn string
function utils.cmd(fn) return string.format("<cmd>lua require('leetcode.command').%s()<cr>", fn) end

---map a key in mode
---@param mode string | "'n'" | "'v'" | "'x'" | "'s'" | "'o'" | "'!'" | "'i'" | "'l'" | "'c'" | "'t'" | "''"
---@param lhs string
---@param rhs string
---@param opts? {silent: boolean, expr: boolean}
function utils.map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then options = vim.tbl_extend("force", options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function utils.detect_duplicate_question(title_slug, lang)
    local tabs = utils.get_current_question_tabs()

    for _, q in ipairs(tabs) do
        if title_slug == q.question.q.title_slug and lang == q.question.lang then
            return q.tabpage
        end
    end
end

function utils.get_current_question_tabs()
    ---@class lc.Question.Tab
    ---@field tabpage integer
    ---@field question lc.Question

    ---@type lc.Question.Tab[]
    local questions = {}

    for _, tabp in ipairs(vim.api.nvim_list_tabpages()) do
        local bufs = vim.fn.tabpagebuflist(tabp)

        for _, bufnr in ipairs(bufs) do
            if _Lc_questions[bufnr] then
                table.insert(questions, { tabpage = tabp, question = _Lc_questions[bufnr] })
            end
        end
    end

    return questions
end

-- ---@param module string
-- function utils.add(module)
--
--
-- end

---@param lang string
function utils.filetype(lang)
    local filetypes = {
        cpp = "cpp",
        java = "java",
        python = "py",
        python3 = "py",
        c = "c",
        csharp = "cs",
        javascript = "js",
        typescript = "ts",
        php = "php",
        swift = "swift",
        kotlin = "kt",
        dart = "dart",
        golang = "go",
        ruby = "rb",
        scala = "scala",
        rust = "rs",
        racket = "rkt",
        erlang = "erl",
        elixir = "ex",
    }

    local ft = filetypes[lang]
    assert(ft, "Unknown language: " .. lang)
    return ft
end

return utils
