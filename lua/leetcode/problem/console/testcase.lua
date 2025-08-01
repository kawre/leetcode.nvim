local t = require("leetcode.translator")

---@class leet.problem.console.testcase
---@field console leet.problem.console
local M = Markup.object()

---@param console leet.problem.console
function M:new(console)
    self.console = console
    self.testcases = {}

    self.win = Markup.window({
        box = "horizontal",
        title = "Testcase",
        border = "rounded",
        show = false,
        file = self:path(),
        bo = {
            modifiable = true,
            buftype = "nofile",
        },
        -- on_buf = function()
        --     -- self:handle_buf()
        -- end,
    })
    self.win:on({
        "TextChanged",
        "TextChangedI",
        "TextChangedP",
        "InsertLeave",
    }, function()
        self:draw_extmarks()
    end)
end

---@return string path, boolean existed
function M:path()
    local fn = self.console.problem:filename("txt")
    vim.fn.mkdir(Leet.config.storage.home .. "/testcase", "p")
    self.file = Leet.config.storage.home:joinpath("testcase/" .. fn)
    local existed = self.file:exists()

    -- if not existed then
    self.file:write(self:build_lines(), "w")
    -- end

    return self.file:absolute(), existed
end

function M:build_lines()
    local lines = {}

    local t_list = self.console.problem.problem.testcase_list
    self.testcase_len = #vim.split(t_list[1] or "", "\n")

    for i, case in ipairs(t_list) do
        if i ~= 1 then
            table.insert(lines, "")
        end
        for s in vim.gsplit(case, "\n", { trimempty = true }) do
            table.insert(lines, s)
        end
    end

    -- vim.api.nvim_buf_set_lines(self.win.buf, 0, -1, false, lines)
    return table.concat(lines, "\n")
    -- return self:draw_extmarks()
end

local ns = vim.api.nvim_create_namespace("leet.problem.console.testcase.extmarks")

function M:draw_extmarks()
    if not Leet.config.user.console.testcase.virt_text then
        return
    end

    local md = self.console.problem.problem.meta_data
    if not md.params then
        return
    end

    local buf = self.win.buf
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    local j = 1
    local pad = (" "):rep(2)
    local function get_param(idx)
        return {
            { pad },
            { "", "Operator" },
            { " " },
            { md.params[idx].name, "Comment" },
            { " " },
            { md.params[idx].type, "Type" },
        }
    end

    local invalid = false

    for i, line in ipairs(lines) do
        pcall(function()
            if lines[i - 1] == "" and lines[i] == "" then
                invalid = true
            end
        end)

        if line ~= "" then
            local ok, text = pcall(get_param, j)
            if not ok or invalid then
                text = { { pad }, { (" %s"):format(t("invalid")), "leetcode_error" } }
            end

            vim.api.nvim_buf_set_extmark(buf, ns, i - 1, -1, {
                virt_text = text,
            })
            j = j + 1
        else
            j = 1
        end
    end

    return self
end

function M:content()
    local lines = self.win:lines()
    lines = vim.tbl_filter(function(line)
        return line ~= ""
    end, lines)
    return table.concat(lines, "\n")
end

function M:snapshot(id, data)
    if not data.test_case then
        return
    end
    self.testcases[id] = data.test_case
end

---@return string[][]
function M:by_id(id) --
    local testcases = {} ---@type string[][]

    local i, n = 0, self.testcase_len
    for case in vim.gsplit(self.testcases[id] or "", "\n") do
        local j = math.floor(i / n) + 1

        if not testcases[j] then
            testcases[j] = {}
        end
        table.insert(testcases[j], case)

        i = i + 1
    end

    return testcases
end

return M
