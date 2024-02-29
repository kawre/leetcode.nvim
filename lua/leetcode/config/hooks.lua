---@class lc.Hooks
local hooks = {}

hooks["question_enter"] = {
    vim.schedule_wrap(function(q)
        -- https://github.com/kawre/leetcode.nvim/issues/14
        if q.lang ~= "rust" then
            return
        end
        pcall(function()
            require("rust-tools.standalone").start_standalone_client()
        end)
    end),
}

return hooks
