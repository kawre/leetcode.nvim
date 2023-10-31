local config = require("leetcode.config")
local log = require("leetcode.logger")

local translate = {
    ["Problems"] = "题库",
    ["Statistics"] = "统计学",
    ["Cookie"] = "Cookie",
    ["Cache"] = "缓存",
    ["Exit"] = "退出",
    ["Back"] = "后退",
    ["Menu"] = "菜单",
    ["Loading..."] = "加载中...",
    ["Signed in as"] = "已登录为",
    ["Update"] = "更新",
    ["List"] = "列表",
    ["Random"] = "随机",
    ["Daily"] = "每日",
    ["Delete / Sign out"] = "删除 / 退出",
    ["Sign in"] = "登录",
    ["Sign in (By Cookie)"] = "使用Cookie登录",
    ["Enter cookie"] = "输入 Cookie",
    ["Sign-in successful"] = "登录成功",
    ["Hints"] = "提示",
    ["of"] = "的",
    ["Easy"] = "简单",
    ["Medium"] = "中等",
    ["Hard"] = "困难",
    ["Run"] = "运行",
    ["Submit"] = "提交",
    ["Topics"] = "相关标签",
    ["Premium"] = "高级",
    ["Similar Questions"] = "相似题目",
    ["No similar questions available"] = "没有类似的问题可用",
    ["No topics available"] = "没有可用的主题",
    ["No hints available"] = "没有提示可用",
    ["Drawn question is for premium users only. Please try again"] = "抽选的问题仅供高级用户使用。请再试一次。",
}

local function t(text)
    if not vim.tbl_contains(vim.tbl_keys(translate), text) then
        log.error(("Translation for `%s` not found"):format(text))
        return "?"
    end

    return config.user.domain == "com" and text or translate[text]
end

---@param text string|string[]
return function(text)
    if type(text) == "string" then
        return t(text)
    elseif type(text) == "table" then
        return vim.tbl_map(t, text)
    end
end
