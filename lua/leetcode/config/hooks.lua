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

return hooks
