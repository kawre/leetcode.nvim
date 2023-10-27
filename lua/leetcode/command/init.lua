local log = require("leetcode.logger")
local cmd_opts = require("leetcode.command.options")

---@class lc.Commands
local cmd = {}

---@param old_name string
---@param new_name string
function cmd.deprecate(old_name, new_name)
    log.warn(("`%s` is deprecated, use `%s` instead."):format(old_name, new_name))
end

function cmd.cache_update() require("leetcode.cache").update() end

---@param options table<string, string[]>
function cmd.problems(options)
    local async = require("plenary.async")
    local problems = require("leetcode.cache.problemlist")

    async.run(
        function() return problems.get() end,
        function(res) require("leetcode.pickers.question").pick(res, options) end
    )
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

function cmd.info()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then return log.error("No current question found") end
    q.hints:toggle()
end

function cmd.hints()
    cmd.deprecate("Leet hints", "Leet info")
    cmd.info()
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

---@return string, string[], string[]
function cmd.parse(args)
    local parts = vim.split(vim.trim(args), "%s+")
    if parts[1]:find("Leet") then table.remove(parts, 1) end
    if args:sub(-1) == " " then parts[#parts + 1] = "" end

    local options = {}
    for _, part in ipairs(parts) do
        local opt = part:match("(.-)=.-")
        if opt then table.insert(options, opt) end
    end

    return table.remove(parts, 1) or "", parts, options
end

---@param t table
local function cmds_keys(t)
    return vim.tbl_filter(function(key) return type(key) == "string" end, vim.tbl_keys(t))
end

function cmd.complete(prefix, args, options, cmds)
    if not cmds then return {} end
    if #args > 0 and not cmds.opts then
        return cmd.complete(table.remove(args, 1), args, cmds[prefix])
    end

    local txt, keys = prefix, cmds_keys(cmds)
    if #args > 0 then
        txt, keys = args[#args], cmds_keys(cmds.opts)
        keys = vim.tbl_filter(function(key) return not vim.tbl_contains(options, key) end, keys)
        keys = vim.tbl_map(function(key) return ("%s="):format(key) end, keys)

        local s = vim.split(txt, "=")
        if s[2] and cmds.opts[s[1]] then
            local vals = vim.split(s[2], ",")
            return vim.tbl_filter(
                function(key)
                    return not vim.tbl_contains(vals, key) and key:find(vals[#vals], 1, true) == 1
                end,
                cmds.opts[s[1]]
            )
        end
    end

    return vim.tbl_filter(
        function(key) return not vim.tbl_contains(args, key) and key:find(txt, 1, true) == 1 end,
        keys or {}
    )
end

function cmd.cmd(args)
    local t = cmd.commands
    local options = {}
    for s in vim.gsplit(args.args, "%s+", { trimempty = true }) do
        local opt = vim.split(s, "=")
        if opt[2] then
            options[opt[1]] = vim.split(opt[2], ",%s*", { trimempty = true })
        else
            t = t[s]
        end
    end

    t[1](options)
end

function cmd.setup()
    vim.api.nvim_create_user_command("Leet", function(args)
        if not pcall(cmd.cmd, args) then log.error(("Invalid command: `%s`"):format(args.args)) end
    end, {
        bar = true,
        bang = true,
        nargs = "?",
        desc = "Leet",
        complete = function(_, line)
            local prefix, args, options = cmd.parse(line)
            return cmd.complete(prefix, args, options, cmd.commands[prefix] or cmd.commands)
        end,
    })
end

cmd.commands = {
    cmd.menu,

    console = { cmd.console },
    info = { cmd.info },
    menu = { cmd.menu },
    tabs = { cmd.question_tabs },
    lang = { cmd.change_lang },
    run = { cmd.q_run },
    submit = { cmd.q_submit },
    fix = { cmd.fix },
    list = { cmd.problems, opts = cmd_opts.list },
    desc = {
        toggle = { cmd.desc_toggle },
    },

    --deprecated
    hints = { cmd.hints },
}

return cmd
