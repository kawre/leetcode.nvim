local log = require("leetcode.logger")

---@class lc.Commands
local cmd = {}

function cmd.cache_update() require("leetcode.cache").update() end

function cmd.problems()
    local async = require("plenary.async")
    local problems = require("leetcode.cache.problemlist")

    async.run(function()
        local res = problems.get()
        return res
    end, function(res) require("leetcode.pickers.question").pick(res) end)
end

---@param cb? function
function cmd.cookie_prompt(cb)
    local cookie = require("leetcode.cache.cookie")

    local popup_options = {
        relative = "editor",
        position = {
            row = "50%",
            col = "50%",
        },
        size = 100,
        border = {
            style = "rounded",
            text = {
                top = " Enter cookie ",
                top_align = "left",
            },
        },
        win_options = {
            winhighlight = "Normal:Normal",
        },
    }

    local Input = require("nui.input")
    local input = Input(popup_options, {
        prompt = " 󰆘 ",
        on_submit = function(value)
            local c_ok, err = pcall(cookie.update, value)
            if not c_ok then return log.warn(err) end

            cmd.menu_layout("menu")
            log.info("Sign-in successful")
            if cb then cb() end
        end,
    })

    input:map("n", { "<Esc>", "q" }, function() input:unmount() end)
    input:mount()
end

---Sign out
function cmd.delete_cookie()
    log.warn("You're now signed out")
    local cookie = require("leetcode.cache.cookie")
    pcall(cookie.delete)

    cmd.menu_layout("signin")
end

---Merge configurations into default configurations and set it as user configurations.
---
---@return lc.UserStatus | nil
function cmd.authenticate() require("leetcode.api.auth").user() end

---Merge configurations into default configurations and set it as user configurations.
---
--@param theme lc-db.Theme
function cmd.qot()
    local problems = require("leetcode.api.problems")
    local Question = require("leetcode.ui.question")

    problems.question_of_today(function(qot) Question:init(qot) end)
end

function cmd.random_question()
    local problems = require("leetcode.cache.problemlist")
    local question = require("leetcode.api.question")

    local q = question.random()
    if q then
        local item = problems.get_by_title_slug(q.title_slug) or {}
        require("leetcode.ui.question"):init(item)
    end
end

function cmd.menu()
    local ok, tabp = pcall(vim.api.nvim_win_get_tabpage, _Lc_Menu.winid)
    if ok then vim.api.nvim_set_current_tabpage(tabp) end
end

---@param layout layouts
function cmd.menu_layout(layout) _Lc_Menu:set_layout(layout) end

function cmd.question_tabs() require("leetcode.pickers.question-tabs").pick() end

function cmd.change_lang()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then return log.warn("No current question found") end

    require("leetcode.pickers.language").pick(q)
end

function cmd.desc_toggle()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then return log.error("No current question found") end

    q.description:toggle()
end

function cmd.console()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then return log.error("No current question found") end
    q.console:toggle()
end

function cmd.hints()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then return log.error("No current question found") end
    q.hints:toggle()
end

function cmd.q_run()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then return log.warn("No current question found") end
    q.console:run()
end

function cmd.q_submit()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then return log.warn("No current question found") end
    q.console:submit()
end

function cmd.fix()
    require("leetcode.cache.cookie").delete()
    require("leetcode.cache.problemlist").delete()
    vim.cmd("qa!")
end

cmd.commands = {
    console = cmd.console,
    hints = cmd.hints,
    menu = cmd.menu,
    tabs = cmd.question_tabs,
    lang = cmd.change_lang,
    run = cmd.q_run,
    submit = cmd.q_submit,
    fix = cmd.fix,

    desc = {
        toggle = cmd.desc_toggle,
    },
}

---@return string, string[]
function cmd.parse(args)
    local parts = vim.split(vim.trim(args), "%s+")
    if parts[1]:find("Leet") then table.remove(parts, 1) end
    if args:sub(-1) == " " then parts[#parts + 1] = "" end
    return table.remove(parts, 1) or "", parts
end

function cmd.complete(_, line)
    local prefix, args = cmd.parse(line)
    if #args > 0 then return cmd.complete(prefix, args[#args]) end

    local tbl = type(cmd.commands[_]) == "table" and cmd.commands[_] --[[@as table]]
        or cmd.commands

    return vim.tbl_filter(
        function(key) return key:find(prefix, 1, true) == 1 end,
        vim.tbl_keys(tbl)
    )
end

function cmd.cmd(args)
    local arguments = vim.split(args.args, "%s+")
    if vim.tbl_isempty(args.fargs) then return cmd.menu() end
    local last = arguments[#arguments]

    local tbl = cmd.commands
    for i = 1, #arguments - 1 do
        tbl = cmd.commands[arguments[i]] --[[@as table]]
    end

    tbl[last]()
end

function cmd.setup()
    vim.api.nvim_create_user_command("Leet", function(args)
        if not pcall(cmd.cmd, args) then log.error(("Invalid command: `%s`"):format(args.args)) end
    end, {
        bar = true,
        bang = true,
        nargs = "?",
        desc = "Leet",
        complete = cmd.complete,
    })
end

return cmd
