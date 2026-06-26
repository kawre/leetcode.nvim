---@class lc.Hooks
local hooks = {}

hooks["problem_description_open"] = {}

hooks["question_enter"] = {
    function(q)
        -- https://github.com/kawre/leetcode.nvim/issues/14
        if q.lang == "rust" then
            pcall(function()
                require("rust-tools.standalone").start_standalone_client()
            end)
        end
    end,
    function(q)
        require("leetcode.utils").exec_hooks("timer_start", q)
    end,
}

hooks["upload_submit_result"] = {
    function(q, _, item)
        if item and item._ and item._.success then
            require("leetcode.utils").exec_hooks("timer_stop", q)
        end
    end,
}

hooks["upload_test_result"] = {}

hooks["on_test_result"] = {}

hooks["timer_start"] = {
    function(q)
        q:start_timer_display()
    end,
}

hooks["timer_stop"] = {
    function(q)
        q:stop_timer_display()
    end,
}

hooks["question_leave"] = {}

return hooks
