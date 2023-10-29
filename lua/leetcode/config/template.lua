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
        open_on_runcode = true, ---@type boolean

        dir = "row", ---@type "col" | "row"

        size = {
            width = "90%", ---@type string | integer
            height = "75%", ---@type string | integer
        },

        result = {
            size = "60%", ---@type string | integer
        },

        testcase = {
            virt_text = true, ---@type boolean

            size = "40%", ---@type string | integer
        },
    },

    description = {
        position = "left", ---@type "top" | "right" | "bottom" | "left"

        width = "40%", ---@type string | integer
    },
}

return M
