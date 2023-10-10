---@alias lc.lang
---| "cpp"
---| "java"
---| "python"
---| "python3"
---| "c"
---| "csharp"
---| "javascript"
---| "typescript"
---| "php"
---| "swift"
---| "kotlin"
---| "dart"
---| "golang"
---| "ruby"
---| "scala"
---| "rust"
---| "racket"
---| "erlang"
---| "elixir"

---@alias lc.sql_lang
---| "pythondata"
---| "mysql"
---| "mssql"
---| "oraclesql"

---@alias lc.domain
---| "com"
---| "cn"

---@class lc.UserConfig
local M = {
    ---@type lc.domain
    domain = "com", -- For now "com" is the only one supported

    ---@type string
    arg = "leetcode.nvim",

    ---@type lc.lang
    lang = "cpp",

    ---@type lc.sql_lang
    sql = "mysql",

    ---@type string
    directory = vim.fn.stdpath("data") .. "/leetcode/",

    ---@type boolean
    logging = true,

    console = {
        ---@type boolean
        open_on_runcode = false,

        size = {
            width = "75%", ---@type string | integer
            height = "75%", ---@type string | integer
        },
        dir = "row", ---@type "col" | "row"
    },

    description = {
        width = "40%", ---@type string | integer
    },
}

return M
