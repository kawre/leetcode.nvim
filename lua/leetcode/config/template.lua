---@class lc.Config
local M = {
    ---@type string
    domain = "com",

    ---@type string
    invoke_name = "leetcode.nvim",

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
}

return M
