local log = require("leetcode.logger")
local arguments = require("leetcode.command.arguments")
local config = require("leetcode.config")
local event = require("nui.utils.autocmd").event
local keys = config.user.keys

local t = require("leetcode.translator")

---@class lc.Commands
local cmd = {}

---@param old_name string
---@param new_name string
function cmd.deprecate(old_name, new_name)
    log.warn(("`%s` is deprecated, use `%s` instead."):format(old_name, new_name))
end

function cmd.cache_update()
    require("leetcode.utils").auth_guard()

    require("leetcode.cache").update()
end

---@param options table<string, string[]>
function cmd.problems(options)
    require("leetcode.utils").auth_guard()

    local p = require("leetcode.cache.problemlist").get()
    require("leetcode.pickers.question").pick(p, options)
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
                top = (" %s "):format(t("Enter cookie")),
                top_align = "left",
            },
        },
        win_options = {
            winhighlight = "Normal:Normal",
        },
    }

    local NuiInput = require("nui.input")
    local input = NuiInput(popup_options, {
        prompt = " 󰆘 ",
        on_submit = function(value)
            local err = cookie.set(value)

            if not err then
                log.info("Sign-in successful")
                cmd.menu_layout("menu")
                pcall(cb, true)
            else
                log.error("Sign-in failed: " .. err)
                pcall(cb, false)
            end
        end,
    })

    input:mount()

    input:map("n", keys.toggle, function() input:unmount() end)
    input:on(event.BufLeave, function() input:unmount() end)
end

function cmd.sign_out()
    log.warn("You're now signed out")
    cmd.delete_cookie()
    cmd.menu_layout("signin")
    cmd.q_close_all()
end

---Sign out
function cmd.delete_cookie()
    config.auth = {}
    local cookie = require("leetcode.cache.cookie")
    cookie.delete()
end

cmd.q_close_all = vim.schedule_wrap(function()
    local utils = require("leetcode.utils")
    local qs = utils.question_tabs()

    for _, tabp in ipairs(qs) do
        tabp.question:unmount()
    end
end)

cmd.expire = vim.schedule_wrap(function()
    local tabp = vim.api.nvim_get_current_tabpage()
    cmd.menu()

    cmd.cookie_prompt(function(success)
        if success then
            if vim.api.nvim_tabpage_is_valid(tabp) then vim.api.nvim_set_current_tabpage(tabp) end
            log.info("Successful re-login")
        else
            cmd.delete_cookie()
            cmd.menu_layout("signin")
            cmd.q_close_all()
        end
    end)
end)

---Merge configurations into default configurations and set it as user configurations.
---
--@param theme lc-db.Theme
function cmd.qot()
    require("leetcode.utils").auth_guard()

    local problems = require("leetcode.api.problems")
    local Question = require("leetcode-ui.question")

    problems.question_of_today(function(qot, err)
        if err then return log.err(err) end
        local problemlist = require("leetcode.cache.problemlist")
        Question(problemlist.get_by_title_slug(qot.title_slug)):mount()
    end)
end

function cmd.random_question(opts)
    require("leetcode.utils").auth_guard()

    local problems = require("leetcode.cache.problemlist")
    local question = require("leetcode.api.question")

    if opts and opts.difficulty then opts.difficulty = opts.difficulty[1]:upper() end
    if opts and opts.status then
        opts.status = ({
            ac = "AC",
            notac = "TRIED",
            todo = "NOT_STARTED",
        })[opts.status[1]]
    end

    local q, err = question.random(opts)
    if err then return log.err(err) end

    local item = problems.get_by_title_slug(q.title_slug) or {}
    local Question = require("leetcode-ui.question")
    Question(item):mount()
end

function cmd.start_with_cmd()
    local leetcode = require("leetcode")
    if leetcode.start(false) then cmd.menu() end
end

function cmd.menu()
    local ok, tabp = pcall(vim.api.nvim_win_get_tabpage, _Lc_Menu.winid)
    if ok then
        vim.api.nvim_set_current_tabpage(tabp)
    else
        log.error(tabp)
    end
end

function cmd.yank()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then return end

    if vim.api.nvim_buf_is_valid(q.bufnr) and vim.api.nvim_win_is_valid(q.winid) then
        vim.api.nvim_set_current_win(q.winid)
        vim.api.nvim_set_current_buf(q.bufnr)

        local start_i, end_i = q:range()
        vim.cmd(("%d,%dyank"):format(start_i, end_i))
    end
end

---@param page lc-menu.page
function cmd.menu_layout(page) _Lc_Menu:set_page(page) end

function cmd.question_tabs() require("leetcode.pickers.question-tabs").pick() end

function cmd.change_lang()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if q then require("leetcode.pickers.language").pick(q) end
end

function cmd.desc_toggle()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if q then q.description:toggle() end
end

function cmd.desc_toggle_stats()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if q then q.description:toggle_stats() end
end

function cmd.console()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if q then q.console:toggle() end
end

function cmd.info()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if q then q.info:toggle() end
end

function cmd.hints()
    -- cmd.deprecate("Leet hints", "Leet info")
    cmd.info()
end

function cmd.q_run()
    local utils = require("leetcode.utils")
    utils.auth_guard()
    local q = utils.curr_question()
    if q then q.console:run() end
end

function cmd.q_submit()
    local utils = require("leetcode.utils")
    utils.auth_guard()
    local q = utils.curr_question()
    if q then q.console:run(true) end
end

function cmd.ui_skills()
    if config.is_cn then return end
    local skills = require("leetcode-ui.popup.skills")
    skills:show()
end

function cmd.ui_languages()
    local languages = require("leetcode-ui.popup.languages")
    languages:show()
end

function cmd.open()
    local utils = require("leetcode.utils")
    utils.auth_guard()
    local q = utils.curr_question()

    if q then
        local command
        local os_name = vim.loop.os_uname().sysname

        if os_name == "Linux" then
            command = string.format("xdg-open '%s'", q.cache.link)
        elseif os_name == "Darwin" then
            command = string.format("open '%s'", q.cache.link)
        else
            -- Fallback to Windows if uname is not available or does not match Linux/Darwin.
            command = string.format("start \"\" \"%s\"", q.cache.link)
        end

        os.execute(command)
    end
end

function cmd.reset()
    local utils = require("leetcode.utils")
    utils.auth_guard()
    local q = utils.curr_question()
    if not q then return end

    local snip = q:get_snippet()
    if not snip then return end

    if vim.api.nvim_buf_is_valid(q.bufnr) then
        vim.api.nvim_buf_set_lines(q.bufnr, 0, -1, false, vim.split(snip, "\n"))
    end
end

function cmd.fix()
    require("leetcode.cache.cookie").delete()
    require("leetcode.cache.problemlist").delete()
    vim.cmd("qa!")
end

---@return string[], string[]
function cmd.parse(args)
    local parts = vim.split(vim.trim(args), "%s+")
    if args:sub(-1) == " " then parts[#parts + 1] = "" end

    local options = {}
    for _, part in ipairs(parts) do
        local opt = part:match("(.-)=.-")
        if opt then table.insert(options, opt) end
    end

    return parts, options
end

---@param t table
local function cmds_keys(t)
    return vim.tbl_filter(function(key)
        if type(key) ~= "string" then return false end
        if key:sub(1, 1) == "_" then return false end

        return true
    end, vim.tbl_keys(t))
end

---@param _ string
---@param line string
---
---@return string[]
function cmd.complete(_, line)
    local args, options = cmd.parse(line:gsub("Leet%s", ""))
    return cmd.rec_complete(args, options, cmd.commands)
end

---@param args string[]
---@param options string[]
---@param cmds table<string,any>
---
---@return string[]
function cmd.rec_complete(args, options, cmds)
    if not cmds or vim.tbl_isempty(args) then return {} end

    if not cmds._args and cmds[args[1]] then
        return cmd.rec_complete(args, options, cmds[table.remove(args, 1)])
    end

    local txt, keys = args[#args], cmds_keys(cmds)
    if cmds._args then
        local option_keys = cmds_keys(cmds._args)
        option_keys = vim.tbl_filter(
            function(key) return not vim.tbl_contains(options, key) end,
            option_keys
        )
        option_keys = vim.tbl_map(function(key) return ("%s="):format(key) end, option_keys)
        keys = vim.tbl_extend("force", keys, option_keys)

        local s = vim.split(txt, "=")
        if s[2] and cmds._args[s[1]] then
            local vals = vim.split(s[2], ",")
            return vim.tbl_filter(
                function(key)
                    return not vim.tbl_contains(vals, key) and key:find(vals[#vals], 1, true) == 1
                end,
                cmds._args[s[1]]
            )
        end
    end

    return vim.tbl_filter(
        function(key) return not vim.tbl_contains(args, key) and key:find(txt, 1, true) == 1 end,
        keys
    )
end

function cmd.exec(args)
    local cmds = cmd.commands

    local options = vim.empty_dict()
    for s in vim.gsplit(args.args:lower(), "%s+", { trimempty = true }) do
        local opt = vim.split(s, "=")

        if opt[2] then
            options[opt[1]] = vim.split(opt[2], ",", { trimempty = true })
        elseif cmds then
            cmds = cmds[s]
        else
            break
        end
    end

    if cmds and type(cmds[1]) == "function" then
        cmds[1](options) ---@diagnostic disable-line
    else
        log.error(("Invalid command: `%s %s`"):format(args.name, args.args))
    end
end

function cmd.setup()
    vim.api.nvim_create_user_command("Leet", cmd.exec, {
        bar = true,
        bang = true,
        nargs = "?",
        desc = "Leet",
        complete = cmd.complete,
    })
end

cmd.commands = {
    cmd.menu,

    menu = { cmd.menu },
    console = { cmd.console },
    info = { cmd.info },
    hints = { cmd.hints },
    tabs = { cmd.question_tabs },
    lang = { cmd.change_lang },
    run = { cmd.q_run },
    test = { cmd.q_run },
    submit = { cmd.q_submit },
    daily = { cmd.qot },
    fix = { cmd.fix },
    yank = { cmd.yank },
    open = { cmd.open },
    reset = { cmd.reset },
    last_submission = { cmd.last_submission },

    list = {
        cmd.problems,

        _args = arguments.list,
    },

    random = {
        cmd.random_question,

        _args = arguments.random,
    },

    desc = {
        cmd.desc_toggle,

        stats = { cmd.desc_toggle_stats },

        toggle = { cmd.desc_toggle },
    },

    cookie = {
        update = { cmd.cookie_prompt },
        delete = { cmd.sign_out },
    },

    cache = {
        update = { cmd.cache_update },
    },
}

return cmd
