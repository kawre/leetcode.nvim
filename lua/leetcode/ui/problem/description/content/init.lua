local markup = require("markup")
local log = require("leetcode.logger")

return markup.Component(function(self)
    local content = self.props
    local html_parser = require("markup.core.parser.html")

    local parts = {}
    for part in vim.gsplit(content, "<p>&nbsp;</p>") do
        table.insert(parts, html_parser(part, "html"):parse())
    end

    return markup.Flex({
        spacing = 2,
        children = parts,
    })
end)
