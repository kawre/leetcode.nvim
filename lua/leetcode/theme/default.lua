---Get highlight group value by name.
---
---@param name string String for looking up highlight group.
---@return table
local function hl(name)
  local highlight = vim.api.nvim_get_hl_by_name(name, true)
  setmetatable(highlight, {
    __index = function(self, key)
      if key == "bg" then return self.background end
      if key == "fg" then return self.foreground end

      return nil
    end,
  })

  return highlight
end

---@alias lc.Theme table<string, table>
---@type lc.Theme
local M = {
  problem = {
    easy = { fg = hl("LcProblemEasy").fg },
    medium = { fg = hl("LeetCodeProblemMedium").fg },
    hard = { fg = hl("LeetCodeProblemHard").fg },
  },
}

return M
