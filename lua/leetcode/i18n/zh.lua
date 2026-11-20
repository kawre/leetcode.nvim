--- The text of the UI in Chinese, as leetcode.cn words it.
---@type leet.i18n.text
local M = {}

local GREETINGS =
	{ morning = "早上好", afternoon = "下午好", evening = "晚上好", night = "夜深了" }
local UNITS = { w = "周", d = "天", h = "小时", m = "分钟" }
local SKILLS = { fundamental = "基础", intermediate = "进阶", advanced = "高级" }
local DIFFICULTIES = { All = "全部", Easy = "简单", Medium = "中等", Hard = "困难" }
local STATUSES = { ac = "已解答", notac = "尝试过", todo = "未解答" }

-- Pages and the launcher
M.welcome = "欢迎"
M.account = "账户"
M.menu = "菜单"
M.problems = "题库"
M.statistics = "统计"
M.loading = "加载中"
M.signing_in = "登录中"
M.continue = "继续"
M.daily_challenge = "每日一题"
M.quit = "退出"
M.quit_desc = "关闭 leetcode.nvim"
M.back = "返回"
M.back_desc = "返回菜单"

-- The dashboard
M.not_signed_in = "未登录"
M.continue_detail = "打开上次做的题目"
M.daily_detail = "打开今天的题目"
M.problems_tile = "浏览、刷新"
M.problems_detail = "全部题目、刷新列表和更多最近记录"
M.random_tile = "随机来一题"
M.random_detail = "随机打开一道题"
M.statistics_tile = "技能、热力图"
M.statistics_detail = "技能、语言和一年的提交"
M.account_tile = "Cookie、退出"
M.account_detail = "会话 Cookie 与退出登录"
M.open_recent_detail = "再次打开"
M.open_hint = "打开"
M.quit_hint = "退出"
M.sign_in = "登录"
M.sign_in_desc = "粘贴你的会话 Cookie"
M.cookie = "Cookie"
M.cookie_desc = "粘贴新的会话 Cookie"
M.sign_out = "退出登录"
M.sign_out_desc = "清除此会话"

function M.greeting(part, name)
	return ("%s，%s"):format(GREETINGS[part] or "你好", name)
end

function M.accepted_rate(rate)
	return ("通过率 %.1f%%"):format(rate)
end

M.date_format = "%-m月%-d日"

M.just_now = "刚刚"

function M.ago(count, unit)
	return ("%d %s前"):format(count, UNITS[unit] or unit)
end

-- The problems page
M.browse = "浏览"
M.browse_desc = "搜索并筛选所有题目"
M.random = "随机一题"
M.random_desc = "帮我挑一道"
M.refresh = "刷新"
M.refresh_desc = "重新获取题目列表"
M.todays_problem = "今日题目"
M.recent = "最近"
M.open = "打开"
M.recent_empty = "你做过的题目会显示在这里"

-- Statistics
M.update = "更新"
M.updating = "更新中"
M.updated = "已更新"
M.nothing_yet = "暂无数据"
M.languages = "语言"
M.solved_count = "已解答"
-- After a number each, as "123 次提交".
M.submissions = "次提交"
M.active_days = "天有提交"
M.best_streak = "天最长连续"

function M.skill(skill)
	return SKILLS[skill] or skill
end

function M.month(month)
	return ("%d月"):format(month)
end

-- Problems and their state
function M.difficulty(difficulty)
	local name = difficulty:sub(1, 1):upper() .. difficulty:sub(2):lower()
	return DIFFICULTIES[name] or difficulty
end

function M.status(status)
	return STATUSES[status] or STATUSES.todo
end

-- The browser
M.search_problems = "搜索题目"
M.to_search = "搜索"
M.no_matches = "没有符合筛选条件的题目"
M.any = "全部"
M.todo = "未开始"
M.free = "免费"

function M.of_total(total)
	return (" / %d"):format(total)
end

-- The description
M.premium = "会员"
M.hints = "提示"
M.topics = "相关标签"
M.similar_questions = "相似题目"
M.no_hints = "暂无提示"

function M.acceptance(rate, total)
	return ("通过率 %s，共 %s 次提交"):format(rate, total)
end

-- The console
M.tab_testcase = "测试用例"
M.tab_result = "测试结果"
M.add = "添加"
M.remove = "删除"
M.reset = "重置"
M.edit = "编辑"
M.switch = "切换"
M.results_empty = "运行代码，看看结果如何。"
M.results_how = "%s 运行测试用例，%s 提交判题"

function M.case(index)
	return ("用例 %d"):format(index)
end

-- The judge at work
M.step_queued = "排队中"
M.step_judging = "判题中"
M.step_result = "结果"
M.judging_submit = "正在提交你的代码"
M.judging_run = "正在运行测试用例"
M.header_submitting = "提交中…"
M.header_running = "运行中…"

-- Results
M.runtime = "执行用时"
M.memory = "消耗内存"
M.beats = "击败"
M.input = "输入"
M.output = "输出"
M.expected = "预期结果"
M.use_testcase = "添加到测试用例"
M.last_input = "最后执行的输入"
M.stdout = "标准输出"
M.fullscreen = "全屏"
M.show_all = "显示全部"
M.close = "关闭"
M.judge_failed = "判题出错，不是你的代码有问题。请再运行一次。"
M.too_soon = "过于频繁"
M.run_failed = "运行失败"
M.runner_busy = "正在运行中，请稍候"
M.something_went_wrong = "出错了"
M.too_soon_hint = "LeetCode 每隔几秒才接受一次运行。请稍等片刻，再 %s。"

function M.passed(correct, total)
	return ("通过 %d/%d"):format(correct, total)
end

function M.lines(count)
	return ("%d 行"):format(count)
end

function M.more_lines(count)
	return ("… 还有 %d 行"):format(count)
end

function M.invalid_case(index)
	return ("用例 %d 不是此题的有效输入。"):format(index)
end

function M.edit_case(index)
	return ("编辑用例 %d"):format(index)
end

function M.opening(title)
	return ("正在打开 %s"):format(title)
end
M.opening_daily = "正在打开每日一题"
M.drawing_random = "正在随机挑选题目"

return M
