-- Minimal setup for the UI tests. Paths can be overridden from the environment.
local data = vim.fn.stdpath("data")
local markup = vim.env.MARKUP_PATH or vim.fn.getcwd() .. "/../markup.nvim"

vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.rtp:prepend(markup)
vim.opt.rtp:append(data .. "/lazy/plenary.nvim")
vim.opt.rtp:append(data .. "/lazy/nui.nvim")
vim.opt.rtp:append(data .. "/site")
vim.opt.rtp:append(markup .. "/deps/mini.test")

if #vim.api.nvim_list_uis() == 0 then
	require("mini.test").setup()
end
