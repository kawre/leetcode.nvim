local config = require("leetcode.config")

---@class lc.translate
local translate = {
    ["problems"] = "题库",
    ["statistics"] = "统计",
    ["cookie"] = "Cookie",
    ["cache"] = "缓存",
    ["exit"] = "退出",
    ["back"] = "后退",
    ["menu"] = "菜单",
    ["loading..."] = "加载中...",
    ["signed in as"] = "已登录为",
    ["update"] = "更新",
    ["list"] = "列表",
    ["random"] = "随机",
    ["daily"] = "每日",
    ["delete / sign out"] = "删除 / 退出",
    ["sign in"] = "登录",
    ["sign in (by cookie)"] = "使用Cookie登录",
    ["enter cookie"] = "输入 Cookie",
    ["sign-in successful"] = "登录成功",
    ["sign-in failed"] = "登录失败",
    ["hints"] = "提示",
    ["of"] = "的",
    ["run"] = "运行",
    ["submit"] = "提交",
    ["result"] = "执行结果",
    ["testcases"] = "测试用例",
    ["topics"] = "相关标签",
    ["premium"] = "高级",
    ["similar questions"] = "相似题目",
    ["no similar questions available"] = "没有类似的问题可用",
    ["no topics available"] = "没有可用的主题",
    ["no hints available"] = "没有提示可用",
    ["drawn question is for premium users only. please try again"] = "抽选的问题仅供高级用户使用。请再试一次。",
    ["please verify your email address in order to use your account"] = "请验证您的电子邮件地址以便使用您的账户",
    ["use testcase"] = "添加到测试用例",
    ["available languages"] = "可用语言",
    ["languages"] = "语言",
    ["language already set to"] = "语言已设置为",
    ["skills"] = "技能",
    ["runtime"] = "时间",
    ["runtime error"] = "执行出错",
    ["memory"] = "内存",
    ["beats"] = "击败",
    ["testcases passed"] = "个通过的测试用例",
    ["last executed input"] = "最后执行的输入",
    ["reset"] = "重置",
    ["input"] = "输入",
    ["output"] = "输出",
    ["expected"] = "预期结果",
    ["invalid"] = "无效",
    ["question info"] = "问题信息",
    ["select a question"] = "选择一个问题",
    ["question is for premium users only"] = "问题仅限高级用户使用",
    ["no questions opened"] = "没有打开的问题",
    ["no current question found"] = "未找到当前问题",
    ["you're now signed out"] = "您现在已注销",
    ["you have attempted to run code too soon"] = "你的提交过于频繁，请稍候重试。",
    ["stdout"] = "标准输出",
    ["submissions"] = "过去一年共提交",
    ["active days"] = "累计提交天数",
    ["max streak"] = "连续提交",
    ["more challenges"] = "更多挑战",
    ["session"] = "进度",

    -- difficulty
    ["all"] = "所有",
    ["easy"] = "简单",
    ["medium"] = "中等",
    ["hard"] = "困难",

    -- status_msg
    ["accepted"] = "通过",
    ["wrong answer"] = "解答错误",
    ["compile error"] = "编译出错",
    ["time limit exceeded"] = "超出时间限制",
    ["output limit exceeded"] = "超出输出限制",
    -- ["internal error"] = "internal error",
    ["memory limit exceeded"] = "超出内存限制",
    ["invalid testcase"] = "测试用例非有效值",

    -- err
    ["http error"] = "HTTP 错误",
    ["curl failed"] = "curl 失败",

    -- interpreter status
    ["pending…"] = "运行中…",
    ["judging…"] = "判题中…",
    ["finished"] = "完成",
    ["failed"] = "失败",
}

---@param text string
local function t(text)
    local keys = vim.tbl_map(function(key)
        return key:lower()
    end, vim.tbl_keys(translate))

    if not vim.tbl_contains(keys, text:lower()) then
        return text
    end
    return translate[text:lower()]
end

return function(text)
    if config.translator and type(text) == "string" then
        return t(text)
    else
        return text
    end
end
