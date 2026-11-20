local m = require("markup")
local i18n = require("leetcode.i18n")
local kit = require("leetcode.ui.kit")

local M = {}

local function number(value)
	return value ~= vim.NIL and tonumber(value) or nil
end

--- How far a submission got, or how long a run took.
---@return any?
function M.detail(item)
	local correct, total = number(item.total_correct), number(item.total_testcases)

	if item._.submission and not item._.success and correct and total and total > 0 then
		return m.inline({
			kit.Bar({
				width = 10,
				-- On the band of the header, which the usual track is lost on.
				style = "leetcode_header_bar_error",
				track = "leetcode_header_bar_track",
				value = function()
					return correct / total
				end,
			}),
			m.inline(" " .. i18n.passed(correct, total), "leetcode_muted"),
		})
	end

	if item._.submission and item._.success then
		local lang = Leet.util.get_lang_by_name(item.pretty_lang)
		return lang and m.inline(lang.icon .. " " .. lang.lang, "leetcode_muted")
	end

	-- LeetCode says "N/A" when there is no time to tell, which reads as noise.
	local runtime = item.status_runtime
	return type(runtime) == "string" and runtime ~= "N/A" and m.inline(runtime, "leetcode_muted")
		or nil
end

---@param item table
---@return "ok"|"error"|"warn"
function M.kind(item)
	local sc = item.status_code
	if sc == 10 then
		return item._.success and "ok" or "error"
	end
	return (sc == 12 or sc == 13 or sc == 14) and "warn" or "error"
end

--- What a run came to, in one line: an icon and title in its color, and how
--- far it got or how long it took.
---@param item table
function M.Status(item)
	local kind = M.kind(item)
	local group = "leetcode_status_" .. kind
	local detail = M.detail(item)
	return m.inline({
		white_space = "nowrap",
		-- Read at a glance from anywhere, so the cursor never needs to go there.
		snap = false,
		m.inline((kind == "ok" and kit.icons.check or kit.icons.cross) .. " ", group),
		m.inline(item._.title or item.status_msg or "", group),
		detail and m.inline({ "   ", detail }),
	})
end

--- A run that ended before the judge saw it, in the colors of `kind`.
---@param title string
---@param kind "warn"|"error"
function M.Notice(title, kind)
	local group = "leetcode_status_" .. kind
	return m.inline({
		white_space = "nowrap",
		snap = false,
		m.inline(kit.icons.cross .. " ", group),
		m.inline(title, group),
	})
end

--- The judge at work, for the header while it is.
---@param submit boolean
function M.Pending(submit)
	return m.inline({
		white_space = "nowrap",
		snap = false,
		m.loader({ style = "leetcode_accent" }),
		m.inline(
			" " .. (submit and i18n.header_submitting or i18n.header_running),
			"leetcode_muted"
		),
	})
end

return M
