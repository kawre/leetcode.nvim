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

---@alias lc.hook
---| "enter"
---| "problem_description_open"
---| "question_enter"
---| "question_leave"
---| "leave"
---| "on_test_result"
---| "upload_submit_result"
---| "upload_test_result"
---| "timer_start"
---| "timer_stop"

---@alias lc.size
---| string
---| number
---| { width: string | number, height: string | number }

---@alias lc.position "top" | "right" | "bottom" | "left"

---@alias lc.direction "col" | "row"

---@alias lc.inject { gap?: number, imports?: (fun(default_imports: string[]): string[])|string|string[], before?: string|string[], after?: string|string[] }

---@alias lc.storage table<"cache"|"home", string>

---@alias lc.picker { provider?: "fzf-lua" | "telescope" | "snacks-picker" }

---@class lc.UserConfig
local M = {
    ---@type string
    arg = "leetcode.nvim",

    ---@type lc.lang
    lang = "cpp",

    cn = { -- leetcode.cn
        enabled = false, ---@type boolean
        translator = true, ---@type boolean
        translate_problems = true, ---@type boolean
    },

    ---@type lc.storage
    storage = {
        home = vim.fn.stdpath("data") .. "/leetcode",
        cache = vim.fn.stdpath("cache") .. "/leetcode",
    },

    ---@type table<string, boolean>
    plugins = {
        non_standalone = false,
    },

    ---@type boolean
    logging = true,

    injector = {}, ---@type table<lc.lang, lc.inject>

    cache = {
        update_interval = 60 * 60 * 24 * 7, ---@type integer 7 days
    },

    editor = {
        reset_previous_code = true, ---@type boolean
        fold_imports = true, ---@type boolean
    },

    console = {
        open_on_runcode = true, ---@type boolean

        dir = "row", ---@type lc.direction

        size = { ---@type lc.size
            width = "90%",
            height = "75%",
        },

        result = {
            size = "60%", ---@type lc.size
        },

        testcase = {
            virt_text = true, ---@type boolean

            size = "40%", ---@type lc.size
        },
    },

    description = {
        position = "left", ---@type lc.position

        width = "40%", ---@type lc.size

        show_stats = true, ---@type boolean

        submissions = {
            enabled = true, ---@type boolean
            height = 10, ---@type lc.size
            limit = 10, ---@type integer
        },
    },

    ---@type lc.picker
    picker = { provider = nil },

    companion = {
        adapter = "submission_service", ---@type string
        model = nil, ---@type string|nil
        auto_submit = true, ---@type boolean
        auto_fence_code = true, ---@type boolean
        prompt_user = true, ---@type boolean
        default_prompt = "Help me understand this problem and my current code.", ---@type string
        window = nil, ---@type table|nil
    },

    ai_assist = {
        enabled = true, ---@type boolean
    },

    hooks = {
        ---@type fun()[]
        ["enter"] = {},

        ---@type fun(question: lc.ui.Question)[]
        ["problem_description_open"] = {},

        ---@type fun(question: lc.ui.Question)[]
        ["question_enter"] = {},

        ---@type fun(question: lc.ui.Question)[]
        ["question_leave"] = {},

        ---@type fun()[]
        ["leave"] = {},

        ---@type fun(question: lc.ui.Question, buffer: string, item_json: table)[]
        ["on_test_result"] = {},

        ---@type fun(question: lc.ui.Question, buffer: string, item_json: table)[]
        ["upload_submit_result"] = {},

        ---@type fun(question: lc.ui.Question, buffer: string, item_json: table)[]
        ["upload_test_result"] = {},

        ---@type fun(question: lc.ui.Question)[]
        ["timer_start"] = {},

        ---@type fun(question: lc.ui.Question)[]
        ["timer_stop"] = {},
    },

    keys = {
        toggle = { "q" }, ---@type string|string[]
        confirm = { "<CR>" }, ---@type string|string[]

        reset_testcases = "r", ---@type string
        use_testcase = "U", ---@type string
        focus_testcases = "H", ---@type string
        focus_result = "L", ---@type string
    },

    ---@type lc.highlights
    theme = {},

    ---@type boolean
    image_support = false,
}

return M
