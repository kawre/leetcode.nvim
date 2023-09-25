local headers = require("leetcode.api.headers")

---@class lc.Api
local api = {}

api.headers = {}

function api.setup() api.headers = headers.get() end

return api
