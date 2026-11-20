local config = require("leetcode.config")

---@class lc.translate
local translate = {
	["problems"] = "题库",
	["statistics"] = "统计",
	["cookie"] = "Cookie",
	["cache"] = "缓存",
	["exit"] = "退出",
	["back"] = "返回",
	["menu"] = "菜单",
	["loading..."] = "加载中...",
	["signed in as"] = "已登录为",
	["update"] = "更新",
	["list"] = "列表",
	["random"] = "随机一题",
	["daily"] = "每日一题",
	["delete / sign out"] = "删除 / 退出登录",
	["sign in"] = "登录",
	["sign in (by cookie)"] = "使用 Cookie 登录",
	["enter cookie"] = "输入 Cookie",
	["sign-in successful"] = "登录成功",
	["sign-in failed"] = "登录失败",
	["hints"] = "提示",
	["run"] = "运行",
	["submit"] = "提交",
	["result"] = "测试结果",
	["testcases"] = "测试用例",
	["topics"] = "相关标签",
	["premium"] = "会员",
	["similar questions"] = "相似题目",
	["no similar questions available"] = "暂无相似题目",
	["no topics available"] = "暂无相关标签",
	["no hints available"] = "暂无提示",
	["drawn question is for premium users only. please try again"] = "抽到的题目仅限会员，请再试一次",
	["please verify your email address in order to use your account"] = "请验证您的电子邮件地址以便使用您的账户",
	["use testcase"] = "添加到测试用例",
	["available languages"] = "可用语言",
	["languages"] = "语言",
	["language already set to"] = "语言已设置为",
	["skills"] = "技能",
	["runtime"] = "执行用时",
	["runtime error"] = "执行出错",
	["memory"] = "消耗内存",
	["beats"] = "击败",
	["testcases passed"] = "个通过的测试用例",
	["last executed input"] = "最后执行的输入",
	["reset"] = "重置",
	["input"] = "输入",
	["output"] = "输出",
	["expected"] = "预期结果",
	["invalid"] = "无效",
	["question info"] = "题目信息",
	["select a question"] = "选择题目",
	["question is for premium users only"] = "该题目仅限会员",
	["no questions opened"] = "没有打开的题目",
	["no current question found"] = "未找到当前题目",
	["you're now signed out"] = "你已退出登录",
	["you have attempted to run code too soon"] = "你的提交过于频繁，请稍后再试",
	["stdout"] = "标准输出",
	["submissions"] = "过去一年共提交",
	["active days"] = "累计提交天数",
	["max streak"] = "连续提交",
	["more challenges"] = "更多挑战",
	["session"] = "进度",

	-- difficulty
	["all"] = "全部",
	["easy"] = "简单",
	["medium"] = "中等",
	["hard"] = "困难",

	-- status_msg
	["accepted"] = "通过",
	["wrong answer"] = "解答错误",
	["compile error"] = "编译出错",
	["time limit exceeded"] = "超出时间限制",
	["output limit exceeded"] = "超出输出限制",
	["internal error"] = "内部出错",
	["memory limit exceeded"] = "超出内存限制",
	["invalid testcase"] = "测试用例非有效值",

	-- err
	["http error"] = "HTTP 错误",
	["curl failed"] = "curl 失败",
	["something went wrong"] = "出错了",
	["runner is busy"] = "正在运行中，请稍候",

	-- interpreter status
	["pending…"] = "排队中…",
	["judging…"] = "判题中…",
	["finished"] = "完成",
	["failed"] = "失败",
}

--- `text` in Chinese, or as it is when there is nothing for it. The spaces
--- around it are kept, as `" Accepted"` becomes `" 通过"`.
---@param text string
local function t(text)
	local before, core, after = text:match("^(%s*)(.-)(%s*)$")
	local translated = translate[core:lower()]
	return translated and before .. translated .. after or text
end

--- Text that is not known ahead, as LeetCode's verdicts and messages, in
--- Chinese when the interface is, see `config.locale()`. The UI's own text has
--- names instead, in `leetcode.i18n`.
---@param text any
return function(text)
	if config.locale() == "zh" and type(text) == "string" then
		return t(text)
	else
		return text
	end
end
