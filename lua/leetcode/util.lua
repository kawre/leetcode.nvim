local config = require("leetcode.config")
local log = require("leetcode.logger")

---@class leet.util
local M = {}

---@param fn string
function M.cmd(fn)
	return ("<cmd>lua require('leetcode.cmd').%s()<cr>"):format(fn)
end

---@param title_slug string
---@param lang lc.lang
function M.detect_duplicate_question(title_slug, lang)
	for _, ap in ipairs(Leet.active_problems) do
		if title_slug == ap.cached.title_slug and lang == ap.lang then
			return ap:tabpage()
		end
	end
end

---@return { tabpage: integer, question: lc.ui.Question }[]
function M.question_tabs()
	local questions = {}

	for _, q in ipairs(Leet.active_problems) do
		local tabp = q:tabpage()
		if tabp then
			table.insert(questions, { tabpage = tabp, question = q })
		end
	end

	return questions
end

---@return leet.problem
function M.curr_question()
	local tabp = vim.api.nvim_get_current_tabpage()

	for _, ap in ipairs(Leet.active_problems) do
		if ap:tabpage() == tabp then
			return ap
		end
	end
end

---@return lc.language
--- Contents of a file, or nil when it cannot be read.
---@param path string
---@return string?
function M.read_file(path)
	local ok, lines = pcall(vim.fn.readfile, path)
	return ok and table.concat(lines, "\n") or nil
end

---@param path string
---@param text string
function M.write_file(path, text)
	vim.fn.writefile(vim.split(text, "\n", { plain = true }), path)
end

---@param slug string
function M.get_lang(slug)
	---@param l lc.language
	return vim.tbl_filter(function(l)
		return l.slug == slug
	end, config.langs)[1]
end

---@return lc.language
function M.get_lang_by_name(name)
	---@param l lc.language
	return vim.tbl_filter(function(l)
		return l.lang == name
	end, config.langs)[1]
end

---@param event lc.hook
---@return fun()[]|nil
function M.get_hooks(event)
	local fns = config.user.hooks[event]
	if not fns then
		return
	end

	if type(fns) == "function" then
		fns = { fns }
	end

	return vim.list_extend(fns, config.hooks[event] or {})
end

---@param event lc.hook
function M.exec_hooks(event, ...)
	local fns = M.get_hooks(event)
	if not fns then
		return log.error("unknown hook event: " .. event)
	end

	for i, fn in ipairs(fns) do
		local ok, msg = pcall(fn, ...)
		if not ok then
			log.error(("bad hook #%d in `%s` event: %s"):format(i, event, msg))
		end
	end
end

---@param content string
---@param translated_content string
function M.translate(content, translated_content)
	if config.is_cn then
		if config.user.cn.translate_problems then
			return translated_content or content
		else
			return content or translated_content
		end
	else
		return content
	end
end

function M.auth_guard()
	if not config.auth.is_signed_in then
		error("User not logged-in", 0)
	end
end

---@param name lc.editor.section
---@param start? boolean
function M.section_tag(name, start)
	if name == "code" then
		return ("@leet %s"):format(start and "start" or "end")
	end
	return ("@leet %s %s"):format(name, start and "start" or "end")
end

return M
