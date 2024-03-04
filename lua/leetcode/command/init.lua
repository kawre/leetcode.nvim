local log = require("leetcode.logger")
local arguments = require("leetcode.command.arguments")
local config = require("leetcode.config")
local event = require("nui.utils.autocmd").event
local api = vim.api

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
                cmd.start_user_session()
            else
                log.error("Sign-in failed: " .. err)
            end

            pcall(cb, not err and true or false)
        end,
    })

    input:mount()

    local keys = config.user.keys
    input:map("n", keys.toggle, function()
        input:unmount()
    end)
    input:on(event.BufLeave, function()
        input:unmount()
    end)
end

function cmd.sign_out()
    cmd.menu()

    log.warn("You're now signed out")
    cmd.delete_cookie()
    cmd.set_menu_page("signin")
end

---Sign out
function cmd.delete_cookie()
    config.auth = {}
    local cookie = require("leetcode.cache.cookie")
    cookie.delete()
end

cmd.q_close_all = function()
    local utils = require("leetcode.utils")
    local qs = utils.question_tabs()

    for _, tabp in ipairs(qs) do
        tabp.question:unmount()
    end
end

function cmd.exit()
    local leetcode = require("leetcode")
    leetcode.stop()
end

cmd.expire = vim.schedule_wrap(function()
    local tabp = api.nvim_get_current_tabpage()
    cmd.menu()

    cmd.cookie_prompt(function(success)
        if success then
            if api.nvim_tabpage_is_valid(tabp) then
                api.nvim_set_current_tabpage(tabp)
            end
            log.info("Successful re-login")
        else
            cmd.sign_out()
        end
    end)
end)

function cmd.qot()
    require("leetcode.utils").auth_guard()

    local problems = require("leetcode.api.problems")
    local Question = require("leetcode-ui.question")

    problems.question_of_today(function(qot, err)
        if err then
            return log.err(err)
        end
        local problemlist = require("leetcode.cache.problemlist")
        Question(problemlist.get_by_title_slug(qot.title_slug)):mount()
    end)
end

function cmd.random_question(opts)
    require("leetcode.utils").auth_guard()

    local problems = require("leetcode.cache.problemlist")
    local question = require("leetcode.api.question")

    if opts and opts.difficulty then
        opts.difficulty = opts.difficulty[1]:upper()
    end
    if opts and opts.status then
        opts.status = ({
            ac = "AC",
            notac = "TRIED",
            todo = "NOT_STARTED",
        })[opts.status[1]]
    end

    local q, err = question.random(opts)
    if err then
        return log.err(err)
    end

    local item = problems.get_by_title_slug(q.title_slug) or {}
    local Question = require("leetcode-ui.question")
    Question(item):mount()
end

function cmd.start_with_cmd()
    local leetcode = require("leetcode")
    if leetcode.start(false) then
        cmd.menu()
    end
end

function cmd.menu()
    local winid, bufnr = _Lc_state.menu.winid, _Lc_state.menu.bufnr
    local ok, tabp = pcall(api.nvim_win_get_tabpage, winid)

    if ok then
        api.nvim_set_current_tabpage(tabp)
        api.nvim_win_set_buf(winid, bufnr)
    else
        _Lc_state.menu:remount()
    end
end

function cmd.yank()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then
        return
    end

    if
        (q.bufnr and api.nvim_buf_is_valid(q.bufnr))
        and (q.winid and api.nvim_win_is_valid(q.winid))
    then
        api.nvim_set_current_win(q.winid)
        api.nvim_set_current_buf(q.bufnr)

        local start_i, end_i, lines = q:range()
        vim.cmd(("%d,%dyank"):format(start_i or 1, end_i or #lines))
    end
end

---@param page lc-menu.page
function cmd.set_menu_page(page)
    _Lc_state.menu:set_page(page)
end

function cmd.start_user_session() --
    cmd.set_menu_page("menu")
    config.stats.update()
end

function cmd.question_tabs()
    require("leetcode.pickers.question-tabs").pick()
end

function cmd.change_lang()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if q then
        require("leetcode.pickers.language").pick(q)
    end
end

function cmd.desc_toggle()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if q then
        q.description:toggle()
    end
end

function cmd.desc_toggle_stats()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if q then
        q.description:toggle_stats()
    end
end

function cmd.console()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if q then
        q.console:toggle()
    end
end

function cmd.info()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if q then
        q.info:toggle()
    end
end

function cmd.hints()
    -- cmd.deprecate("Leet hints", "Leet info")
    cmd.info()
end

function cmd.q_run()
    local utils = require("leetcode.utils")
    utils.auth_guard()
    local q = utils.curr_question()
    if q then
        q.console:run()
    end
end

function cmd.q_submit()
    local utils = require("leetcode.utils")
    utils.auth_guard()
    local q = utils.curr_question()
    if q then
        q.console:run(true)
    end
end

function cmd.ui_skills()
    if config.is_cn then
        return
    end
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
    if not q then
        return
    end

    q:set_lines()
end

function cmd.last_submit()
    local utils = require("leetcode.utils")
    utils.auth_guard()
    local q = utils.curr_question()
    if not q then
        return
    end

    local question_api = require("leetcode.api.question")
    question_api.latest_submission(q.q.id, q.lang, function(res, err) --
        if err then
            if err.status == 404 then
                log.error("You haven't submitted any code!")
            else
                log.err(err)
            end

            return
        end

        if type(res) == "table" and res.code then
            q:set_lines(res.code)
        else
            log.error("Something went wrong")
        end
    end)
end

function cmd.restore()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then
        return
    end

    if
        (q.winid and api.nvim_win_is_valid(q.winid))
        and (q.bufnr and api.nvim_buf_is_valid(q.bufnr))
    then
        api.nvim_win_set_buf(q.winid, q.bufnr)
    end

    q.description:show()
    local winid, bufnr = q.description.winid, q.description.bufnr

    if
        (winid and api.nvim_win_is_valid(winid)) --
        and (bufnr and api.nvim_buf_is_valid(bufnr))
    then
        api.nvim_win_set_buf(winid, bufnr)
    end
end

function cmd.inject()
    local utils = require("leetcode.utils")
    local q = utils.curr_question()
    if not q then
        return
    end

    if q.bufnr and api.nvim_buf_is_valid(q.bufnr) then
        local start_i, end_i = q:range(true)
        local not_found = {}

        if not start_i then
            table.insert(not_found, "`@leet start`")
        else
            local before = q:inject(true)
            if before then
                api.nvim_buf_set_lines(q.bufnr, 0, start_i - 1, false, vim.split(before, "\n"))
            end
        end

        if not end_i then
            table.insert(not_found, "`@leet end`")
        else
            local after = q:inject(false)
            if after then
                api.nvim_buf_set_lines(q.bufnr, end_i + 1, -1, false, vim.split(after, "\n"))
            end
        end

        if not vim.tbl_isempty(not_found) then
            log.error(table.concat(not_found, " and ") .. " not found")
        end
    end
end

function cmd.get_active_session()
    local sessions = config.sessions.all
    return vim.tbl_filter(function(s)
        return s.is_active
    end, sessions)[1]
end

function cmd.get_session_by_name(name)
    local sessions = config.sessions.all

    name = name:lower()
    if name == config.sessions.default then
        name = ""
    end
    return vim.tbl_filter(function(s)
        return s.name:lower() == name
    end, sessions)[1]
end

function cmd.change_session(opts)
    require("leetcode.utils").auth_guard()

    local name = opts.name[1] or config.sessions.default

    local session = cmd.get_session_by_name(name)
    if not session then
        return log.error("Session not found")
    end

    local stats_api = require("leetcode.api.statistics")
    stats_api.change_session(session.id, function(_, err)
        if err then
            return log.err(err)
        end
        log.info(("Session changed to `%s`"):format(name))
        config.stats.update()
    end)
end

function cmd.create_session(opts)
    require("leetcode.utils").auth_guard()

    local name = opts.name[1]
    if not name then
        return log.error("Session name not provided")
    end

    local stats_api = require("leetcode.api.statistics")
    stats_api.create_session(name, function(_, err)
        if err then
            return log.err(err)
        end
        log.info(("session `%s` created"):format(name))
    end)
end

function cmd.update_sessions()
    require("leetcode.utils").auth_guard()

    config.stats.update_sessions()
end

function cmd.fix()
    require("leetcode.cache.cookie").delete()
    require("leetcode.cache.problemlist").delete()
    vim.cmd("qa!")
end

---@return string[], string[]
function cmd.parse(args)
    local parts = vim.split(vim.trim(args), "%s+")
    if args:sub(-1) == " " then
        parts[#parts + 1] = ""
    end

    local options = {}
    for _, part in ipairs(parts) do
        local opt = part:match("(.-)=.-")
        if opt then
            table.insert(options, opt)
        end
    end

    return parts, options
end

---@param tbl table
local function cmds_keys(tbl)
    return vim.tbl_filter(function(key)
        if type(key) ~= "string" then
            return false
        end
        if key:sub(1, 1) == "_" then
            return false
        end
        if tbl[key]._private then
            return false
        end

        return true
    end, vim.tbl_keys(tbl))
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
    if not cmds or vim.tbl_isempty(args) then
        return {}
    end

    if not cmds._args and cmds[args[1]] then
        return cmd.rec_complete(args, options, cmds[table.remove(args, 1)])
    end

    local txt, keys = args[#args], cmds_keys(cmds)
    if cmds._args then
        local option_keys = cmds_keys(cmds._args)
        option_keys = vim.tbl_filter(function(key)
            return not vim.tbl_contains(options, key)
        end, option_keys)
        option_keys = vim.tbl_map(function(key)
            return ("%s="):format(key)
        end, option_keys)
        keys = vim.tbl_extend("force", keys, option_keys)

        local s = vim.split(txt, "=")
        if s[2] and cmds._args[s[1]] then
            local vals = vim.split(s[2], ",")
            return vim.tbl_filter(function(key)
                return not vim.tbl_contains(vals, key) and key:find(vals[#vals], 1, true) == 1
            end, cmds._args[s[1]])
        end
    end

    return vim.tbl_filter(function(key)
        return not vim.tbl_contains(args, key) and key:find(txt, 1, true) == 1
    end, keys)
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
    api.nvim_create_user_command("Leet", cmd.exec, {
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
    exit = { cmd.exit },
    console = { cmd.console },
    info = { cmd.info },
    hints = { cmd.hints },
    tabs = { cmd.question_tabs },
    lang = { cmd.change_lang },
    run = { cmd.q_run },
    test = { cmd.q_run },
    submit = { cmd.q_submit },
    daily = { cmd.qot },
    yank = { cmd.yank },
    open = { cmd.open },
    reset = { cmd.reset },
    last_submit = { cmd.last_submit },
    restore = { cmd.restore },
    inject = { cmd.inject },
    session = {
        change = {
            cmd.change_session,
            _args = arguments.session_change,
        },
        create = {
            cmd.create_session,
            _args = arguments.session_create,
        },
        update = { cmd.update_sessions },
    },
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
    fix = {
        cmd.fix,
        _private = true,
    },
}

return cmd
