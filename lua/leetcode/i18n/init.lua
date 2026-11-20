--- The text of the UI, by name, in the language of `config.locale()`.
---
--- ```lua
--- local i18n = require("leetcode.i18n")
--- i18n.tab_result      -- "Result", or "测试结果"
--- i18n.case(2)         -- "Case 2", or "用例 2"
--- ```
---
--- Each language gives the same names, as text or as a function for text
--- with numbers in it. Chinese, with `ui.locale = "zh"` or on leetcode.cn with
--- `cn.translator` on, falls back to English for what it lacks, and a name neither has is an
--- error, so a typo shows at once rather than as text that never translates.
---
--- What LeetCode sends, such as verdicts, is not known ahead and goes through
--- `leetcode.translator` instead.

local config = require("leetcode.config")
local en = require("leetcode.i18n.en")

---@class leet.i18n: leet.i18n.text
local M = {}

---@return "en"|"zh"
function M.locale()
	return config.locale()
end

setmetatable(M, {
	__index = function(_, key)
		local value
		if config.locale() == "zh" then
			value = require("leetcode.i18n.zh")[key]
		end
		if value == nil then
			value = en[key]
		end
		if value == nil then
			error(("leetcode.i18n: no text named `%s`"):format(key), 2)
		end
		return value
	end,
})

return M
