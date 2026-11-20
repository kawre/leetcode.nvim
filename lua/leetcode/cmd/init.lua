local log = require("leetcode.logger")
local arguments = require("leetcode.cmd.arguments")
local config = require("leetcode.config")
local api = vim.api

local t = require("leetcode.translator")

---@class leet.cmd
local cmd = {}

--- A task for work that nothing on screen started, shown by a loader in the
--- corner of the editor until it is done.
---@param text string
---@return leet.ui.task
local function corner_task(text)
	local close = require("leetcode.ui.toast")(text)
	return {
		cancelled = function()
			return false
		end,
		done = close,
	}
end

--- Questions being fetched, by slug, so a second press does not open two.
local opening = {}

---@param old_name string
---@param new_name string
function cmd.deprecate(old_name, new_name)
	log.warn(("`%s` is deprecated, use `%s` instead."):format(old_name, new_name))
end

function cmd.cache_update()
	require("leetcode.util").auth_guard()

	require("leetcode.cache").update()
end

---@param options table<string, string[]>
function cmd.problems(options)
	require("leetcode.util").auth_guard()

	local p = require("leetcode.cache.problems").get()
	local picker = require("leetcode.picker")
	picker.question(p, options)
end

---@param cb? function
function cmd.cookie_prompt(cb)
	local cookie = require("leetcode.cache.cookie")

	vim.ui.input({ prompt = t("Enter cookie") .. ": " }, function(value)
		if not value or value == "" then
			return
		end

		-- The menu shows it signing in, rather than everything waiting for LeetCode.
		local before = Leet.menu.page()
		cmd.set_menu_page("loading")

		cookie.set(value, function(err)
			if not err then
				log.info("Sign-in successful")
				cmd.start_user_session()
			else
				cmd.set_menu_page(before ~= "loading" and before or "signin")
				log.error("Sign-in failed: " .. err)
			end

			if type(cb) == "function" then
				cb(not err)
			end
		end)
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

--- Opens the daily challenge, see `cmd.open` for `task`.
---@param task? leet.ui.task
function cmd.qot(task)
	require("leetcode.util").auth_guard()
	task = task or corner_task(require("leetcode.i18n").opening_daily)

	local problems = require("leetcode.api.problems")

	problems.question_of_today(function(qot, err)
		if task.cancelled() then
			return
		end
		if err then
			task.done()
			return log.err(err)
		end
		local problemlist = require("leetcode.cache.problems")
		cmd.open(problemlist.by_slug(qot.title_slug), task)
	end)
end

--- Opens a random question, see `cmd.open` for `task`.
---@param opts? table filters
---@param task? leet.ui.task
function cmd.random_question(opts, task)
	require("leetcode.util").auth_guard()

	local problems_cache = require("leetcode.cache.problems")
	local problems = require("leetcode.api.problems")

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

	task = task or corner_task(require("leetcode.i18n").drawing_random)

	problems.random(opts, function(q, err)
		if task.cancelled() then
			return
		end
		if err then
			task.done()
			return log.err(err)
		end

		local item = problems_cache.by_slug(q.title_slug) or {}
		cmd.open(item, task)
	end)
end

function cmd.start_with_cmd()
	local leetcode = require("leetcode")
	if leetcode.start(false) then
		cmd.menu()
	end
end

function cmd.menu()
	if Leet.menu.win:valid() then
		local _, tabp = pcall(api.nvim_win_get_tabpage, Leet.menu.win.win)
		api.nvim_set_current_tabpage(tabp)
		Leet.menu.win:focus()
	else
		Leet.menu.win:show()
	end
end

function cmd.yank()
	local utils = require("leetcode.util")
	local q = utils.curr_question()
	if not q then
		return
	end

	q:editor_yank_code()
end

---@param page lc-menu.page
function cmd.set_menu_page(page)
	Leet.menu.set_page(page)
end

function cmd.start_user_session() --
	cmd.set_menu_page("menu")
	Leet.menu.refresh()
end

function cmd.question_tabs()
	local picker = require("leetcode.picker")
	picker.tabs()
end

function cmd.change_lang()
	local utils = require("leetcode.util")
	local q = utils.curr_question()
	if q then
		local picker = require("leetcode.picker")
		picker.language(q)
	end
end

function cmd.desc_toggle()
	local utils = require("leetcode.util")
	local q = utils.curr_question()
	if q then
		q.description:toggle()
	end
end

function cmd.desc_toggle_stats()
	local utils = require("leetcode.util")
	local q = utils.curr_question()
	if q then
		q.description:toggle_stats()
	end
end

function cmd.console()
	local utils = require("leetcode.util")
	local q = utils.curr_question()
	if q then
		q.console:toggle()
	end
end

function cmd.info()
	local q = require("leetcode.util").curr_question()
	if q then
		q.description:reveal()
	end
end

function cmd.hints()
	local q = require("leetcode.util").curr_question()
	if q then
		q.description:reveal("hints")
	end
end

function cmd.q_run()
	Leet.guard.auth()

	local q = Leet.util.curr_question()
	if q then
		q.console:run()
	end
end

function cmd.q_submit()
	local utils = require("leetcode.util")
	utils.auth_guard()
	local q = utils.curr_question()
	if q then
		q.console:run(true)
	end
end

function cmd.current()
	return Leet.util.curr_question()
end

---@param cached leet.cache.problem
---@return boolean
--- Opens a question, fetching it without blocking anything.
---
--- `task` comes from what started it, as `kit.use_task` gives: it is done
--- when the question opens or cannot, and once it is cancelled, because what
--- started it is gone, the question does not open at all. Without one a loader
--- in the corner of the editor shows it is on its way.
---@param cached leet.cache.problem
---@param task? leet.ui.task
function cmd.open(cached, task)
	local slug = cached.title_slug
	local tabp = Leet.util.detect_duplicate_question(slug, config.lang)

	if tabp then
		vim.api.nvim_set_current_tabpage(tabp)
		if task then
			task.done()
		end
		return
	end

	-- Already on its way, from another press.
	if opening[slug] then
		if task then
			task.done()
		end
		return
	end

	local title = Leet.util.translate(cached.title or slug, cached.title_cn)
	task = task or corner_task(require("leetcode.i18n").opening(title))
	opening[slug] = true

	Leet.api.problems.by_slug(slug, function(res, err)
		opening[slug] = nil
		if task.cancelled() then
			return
		end
		task.done()

		if not res then
			return log.err(err)
		end
		if res.is_paid_only and not config.auth.is_premium then
			return Markup.log.warn("Problem is for premium users only")
		end
		-- Opened meanwhile, such as from the picker.
		local open = Leet.util.detect_duplicate_question(slug, config.lang)
		if open then
			return vim.api.nvim_set_current_tabpage(open)
		end

		Leet.problem(cached, res)
	end)
end

function cmd.browser_open()
	local utils = require("leetcode.util")
	utils.auth_guard()
	local q = utils.curr_question()

	if q then
		if vim.ui.open then
			vim.ui.open(q.cached.link)
		else
			local command
			local os_name = vim.loop.os_uname().sysname

			if os_name == "Linux" then
				command = string.format("xdg-open '%s'", q.cached.link)
			elseif os_name == "Darwin" then
				command = string.format("open '%s'", q.cached.link)
			else
				-- Fallback to Windows if uname is not available or does not match Linux/Darwin.
				command = string.format("start \"\" \"%s\"", q.cached.link)
			end

			vim.fn.jobstart(command, { detach = true })
		end
	end
end

function cmd.reset()
	local utils = require("leetcode.util")
	utils.auth_guard()
	local q = utils.curr_question()
	if not q then
		return
	end

	q:editor_reset_code()
end

function cmd.last_submit()
	local utils = require("leetcode.util")
	utils.auth_guard()
	local q = utils.curr_question()
	if not q then
		return
	end

	local question_api = require("leetcode.api.problems")
	question_api.latest_submission(q.problem.id, q.lang, function(res, err) --
		if err then
			if err.status == 404 then
				log.error("You haven't submitted any code!")
			else
				log.err(err)
			end

			return
		end

		if type(res) == "table" and res.code then
			---@type string
			local lines = res.code
			q:editor_section_replace(lines, "code")
		else
			log.error("Something went wrong")
		end
	end)
end

function cmd.restore()
	local utils = require("leetcode.util")
	local q = utils.curr_question()
	if not q then
		return
	end

	if q:valid() then
		api.nvim_win_set_buf(q.win, q.buf)
	end

	q.description:show()
end

function cmd.inject()
	local utils = require("leetcode.util")
	local q = utils.curr_question()
	if not q then
		return
	end

	if q.buf and api.nvim_buf_is_valid(q.buf) then
		local range = q:editor_section_range("code")

		if not range:is_valid_or_log() then
			return
		end

		local lines = table.concat(range.lines, "\n", range.start_i, range.end_i)

		q:editor_reset()
		q:editor_section_replace(lines, "code")
	end
end

function cmd.fold()
	local utils = require("leetcode.util")
	local q = utils.curr_question()
	if not q then
		return
	end

	q:editor_fold_imports(true)
end

function cmd.fix()
	require("leetcode.cache.cookie").delete()
	require("leetcode.cache.problems").delete()
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
	daily = {
		function()
			cmd.qot()
		end,
	},
	yank = { cmd.yank },
	open = { cmd.browser_open },
	reset = { cmd.reset },
	last_submit = { cmd.last_submit },
	restore = { cmd.restore },
	inject = { cmd.inject },
	fold = { cmd.fold },
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
