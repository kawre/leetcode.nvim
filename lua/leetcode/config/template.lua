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
---| "bash"
---| "html"
---| "pythonml"
---| "react"
---| "vanillajs"

---@alias lc.sql
---| "pythondata"
---| "mysql"
---| "mssql"
---| "oraclesql"
---| "postgresql"

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

    ---@type lc.sql
    sql = "mysql",

    ---@type string
    directory = vim.fn.stdpath("data") .. "/leetcode/",

    ---@type boolean
    logging = true,

    console = {
        open_on_runcode = false, ---@type boolean

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
