local Header = require("leetcode.ui.problem.description.header")
local Content = require("leetcode.ui.problem.description.content")

local markup = require("markup")

---@class leet.ui.Problem.Description : markup.Renderer
---@field protected super markup.Renderer
local Description = markup.Renderer:extend("leet.problem.description") ---@diagnostic disable-line: undefined-field

---@param problem leet.ui.Problem
function Description:init(problem)
    Description.super.init(self, {
        minimal = true,
        position = "left",
        config = {
            vertical = true,
            width = 0.4,
        },
    })

    self.problem = problem
    self:build()
end

function Description:build()
    self:set_body({
        Header({
            cache = self.problem.cache,
            info = self.problem.q,
        }),
        Content(),
    })
    self:render()
end

-- function Description:

-- function Description:buf_open()
--     return markup.Inline("Description")
-- end

return Description
