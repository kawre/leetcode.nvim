local M = {}

M.get = function()
  local cookie = require("leetcode.cache.cookie").read()

  return {
    ["Cookie"] = cookie and string.format(
      "LEETCODE_SESSION=%s;csrftoken=%s",
      cookie.leetcode_session,
      cookie.csrftoken
    ) or "",
    ["Content-Type"] = "application/json",
    ["Accept"] = "application/json",
    ["x-csrftoken"] = cookie and cookie.csrftoken or nil,
    ["Referer"] = "https://leetcode.com",
  }
end

return M
