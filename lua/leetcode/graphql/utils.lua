local headers = require("leetcode.api.headers")
local config = require("leetcode.config")

local curl = require("plenary.curl")

local lc = "https://leetcode." .. config.user.domain
local endpoint = lc .. "/graphql"

local M = {}

---@param query string
---@param variables? table optional
---
---@return table
function M.query(query, variables)
  local response = curl.post(endpoint, {
    headers = headers.get(),
    body = vim.json.encode({
      query = query,
      variables = variables or {},
    }),
  })

  local ok, data = pcall(vim.json.decode, response["body"])
  assert(ok and data and data["data"], "Failed to query data")

  return data["data"]
end

return M
