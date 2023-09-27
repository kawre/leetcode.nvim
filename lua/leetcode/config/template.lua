---@class lc.UserConfig
local M = {
    ---@type string
    domain = "com",

    ---@type string
    arg = "leetcode.nvim",

    ---@type string
    lang = "java",

    ---@type
    ---| "pythondata"
    ---| "mysql"
    ---| "mssql"
    ---| "oraclesql"
    sql = "mysql",

    ---@type string
    directory = vim.fn.stdpath("data") .. "/leetcode",

    ---@type boolean
    logging = true,

    menu_tabpage = 1,
    questions_tabpage = 2,

    console = {
        size = {
            width = "75%", ---@type string | integer
            height = "75%", ---@type string | integer
        },
        dir = "row", ---@type "col" | "row"

        result = {
            max_stdout_length = 200,
        },
    },

    description = {
        width = "40%", ---@type string | integer
    },
}

return M
