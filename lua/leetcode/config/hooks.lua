---@class lc.Hooks
local hooks = {}

hooks["question_enter"] = {
    function(q)
        -- https://github.com/kawre/leetcode.nvim/issues/14
        if q.lang == "rust" then
            pcall(function()
                require("rust-tools.standalone").start_standalone_client()
            end)
        end
    end,
}

hooks["upload_submit_result"] = {}

hooks["upload_test_result"] = {}

hooks["timer_start"] = {}

hooks["timer_stop"] = {
    function(q)
        q:stop_timer_display()
    end,
}

hooks["question_leave"] = {}

return hooks
