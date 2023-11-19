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

---@alias lc.hook
---| "LeetEnter"
---| "LeetQuestionNew"

---@class lc.UserConfig
local M = {
    ---@type string
    arg = "leetcode.nvim",

    ---@type lc.lang
    lang = "cpp",

    cn = { -- leetcode.cn
        enabled = false, ---@type boolean
        translate_problems = true, ---@type boolean
        translator = true, ---@type boolean
    },

    ---@type string
    directory = vim.fn.stdpath("data") .. "/leetcode/",

    ---@type boolean
    logging = true,

    cache = {
        update_interval = 60 * 60 * 24 * 7, ---@type integer 7 days
    },

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

    hooks = {
        ---@type fun()[]
        LeetEnter = {},

        ---@type fun(question: { lang: string })[]
        LeetQuestionNew = {},
    },

    ---@type boolean
    image_support = false, -- setting this to `true` will disable question description wrap
}

return M
