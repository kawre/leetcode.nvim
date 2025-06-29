local Spinner = require("leetcode.logger.spinner")

---@class lc.Judge : lc.Spinner
local Judge = {}
Judge.__index = Judge
setmetatable(Judge, Spinner)

local check_state = {
    ["PENDING"] = "Pending",
    ["STARTED"] = "Judging",
    ["SUCCESS"] = "Finished",
    ["FAILURE"] = "Failed", -- CODE: 16
}

function Judge:from_state(state)
    self:soft_update(check_state[state])

    if state == "PENDING" then
        self:use("points")
    else
        self:use("dot")
    end
end

function Judge:init()
    local spinner = Spinner:start(check_state["PENDING"], "points")
    return setmetatable(spinner, Judge)
end

return Judge
