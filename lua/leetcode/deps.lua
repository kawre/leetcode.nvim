--- What leetcode.nvim needs besides Neovim: markup.nvim, the library it draws
--- its UI with, at a version it works with, with its engine built.
local M = {}

--- The oldest markup.nvim that works. lazy.lua asks lazy.nvim for the same.
M.markup = "0.2.0"

--- How to get markup.nvim, for every way of installing it.
local INSTALL = table.concat({
    "lazy.nvim installs it by itself on the next start of Neovim.",
    "With another plugin manager, add https://github.com/kawre/markup.nvim and run",
    "`nvim -l build.lua` in its directory, which downloads its engine.",
    "To stay on the version before it, pin leetcode.nvim to the tag v0.3.1.",
}, "\n")

--- Loads a module, for tests to replace.
---@param name string
---@return boolean ok, any module
function M.load(name)
    return pcall(require, name)
end

--- What is missing, or nil when markup.nvim is ready.
---@return string?
function M.check()
    -- markup.config needs no engine, so it says the version of a plugin whose
    -- engine is not built yet.
    local ok, config = M.load("markup.config")
    if not ok then
        return "leetcode.nvim now needs markup.nvim, which it draws its UI with.\n" .. INSTALL
    end

    local version = type(config) == "table" and config.version or nil
    if not version or vim.version.lt(version, M.markup) then
        return ("leetcode.nvim needs markup.nvim %s or newer, this one is %s. Update it."):format(
            M.markup,
            version or "older than 0.2.0"
        )
    end

    local built, err = M.load("markup.core")
    if not built then
        return "markup.nvim is there, but not its engine. Run `nvim -l build.lua` in the "
            .. "directory of markup.nvim, or update it with your plugin manager.\n"
            .. tostring(err)
    end
end

--- Says what is missing, once per session, and whether markup.nvim is ready.
---@return boolean
function M.ensure()
    local problem = M.check()
    if problem and not M.said then
        M.said = true
        vim.notify(
            problem .. "\nSee :checkhealth leetcode",
            vim.log.levels.ERROR,
            { title = "leetcode.nvim" }
        )
    end
    return problem == nil
end

return M
