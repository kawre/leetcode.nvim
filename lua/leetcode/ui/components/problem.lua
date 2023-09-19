local log = require("leetcode.logger")

local Text = require("nui.text")
local Line = require("nui.line")
local Layout = require("nui.layout")

local utils = require("leetcode.utils")

---@class lc.Ui.Components.Problem
local M = {}

---@param title any
function M.title(title)
  local line = Line()

  line:append(title.questionFrontendId .. ". " .. title.title)

  return line
end

---@param title_slug string
function M.link(title_slug)
  local line = Line()

  line:append("https://leetcode.com/problems/" .. title_slug .. "/", "Comment")
  line:append("")

  return line
end

---@param title any
function M.stats(title)
  local line = Line()

  line:append(
    title.difficulty,
    title.difficulty == "Easy" and "DiagnosticOk"
      or title.difficulty == "Medium" and "DiagnosticWarn"
      or "DiagnosticError"
  )
  line:append(" | ")
  line:append(title.likes .. "  ", "Comment")
  line:append(title.dislikes .. "  ", "Comment")

  return line
end

---@param content any
function M.content(content)
  local line = Line()

  local s = vim.split(content.content, "\n\n<p>&nbsp;</p>\n", { trimempty = true })

  local desc = M.description(s[1])
  local exam = M.examples(s[2])
  local cons = M.constrains(s[3])
  local foll = M.follow_up(s[4])

  line:append({ desc, exam, cons, foll })

  return line
end

---@param p string
local parse_paragraph = function(p)
  -- for s in vim.gsplit(p, " ", { trimempty = true }) do
  --   log.info(s)
  -- end

  local ts = vim.treesitter
  local parser = ts.get_string_parser(p, "html")

  local tree = parser:parse()[1]
  local function get_text(node)
    local text = {}
    for _, child in ipairs(node) do
      if child:type() == "text" then
        table.insert(text, child:subtree_text())
      elseif child:named() then
        table.insert(text, get_text(child))
      end
    end
    return table.concat(text)
  end
  local text = get_text(tree:root())

  log.info(text)
end

---@param description string
function M.description(description)
  local lines = { "Description:" }

  for v in vim.gsplit(description, "\n\n", { trimempty = true }) do
    parse_paragraph(utils.strip_html_tag(v, "p"))
  end
end

---@param examples string
function M.examples(examples) end

---@param constrains string
function M.constrains(constrains) end

---@param follow_up string
function M.follow_up(follow_up) end

return M
