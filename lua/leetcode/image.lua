--- Images of problem descriptions, downloaded once and kept as PNG, which is
--- what Neovim can show. Other formats are converted with whatever is there.

local m = require("markup")
local config = require("leetcode.config")

---@class leet.image
local M = {}

local loading = {} ---@type table<string, fun(): string?>

local PNG_SIGNATURE = "\137PNG\r\n\26\n"

--- Whether images can be shown at all: asked for, and Neovim can draw them.
---@return boolean
function M.enabled()
	return config.user.image_support and Markup.image.available() or false
end

---@return string
local function dir()
	return vim.fs.joinpath(config.storage.cache, "images")
end

--- A command turning `from` into a PNG at `to`, or nothing to do it with.
---@param from string
---@param to string
---@return string[]?
function M.converter(from, to)
	if vim.fn.executable("magick") == 1 then
		return { "magick", from .. "[0]", "png:" .. to }
	elseif vim.fn.executable("convert") == 1 then
		return { "convert", from .. "[0]", "png:" .. to }
	elseif vim.fn.executable("ffmpeg") == 1 then
		return { "ffmpeg", "-loglevel", "error", "-y", "-i", from, "-frames:v", "1", "-f", "image2", to }
	end
end

---@param path string
---@return string?
local function read(path)
	local ok, data = pcall(vim.fn.readblob, path)
	return ok and data or nil
end

--- Makes `source` a PNG at `target`, then calls `done` with its bytes.
local function settle(source, target, done)
	local head = read(source) or ""
	if head:sub(1, 8) == PNG_SIGNATURE then
		vim.uv.fs_rename(source, target)
		return done(read(target))
	end

	local command = M.converter(source, target)
	if not command then
		os.remove(source)
		return done(nil)
	end

	vim.system(command, {}, function(result)
		vim.schedule(function()
			os.remove(source)
			done(result.code == 0 and read(target) or nil)
		end)
	end)
end

--- The bytes of an image as a PNG, once they are there.
---@param url string
---@return fun(): string?
function M.load(url)
	if loading[url] then
		return loading[url]
	end

	local data = m.signal(nil)
	loading[url] = data

	vim.fn.mkdir(dir(), "p")
	local target = vim.fs.joinpath(dir(), vim.fn.sha256(url) .. ".png")
	if vim.uv.fs_stat(target) then
		data(read(target))
		return data
	end

	local source = target .. ".download"
	vim.system({ "curl", "--silent", "--fail", "--location", "--output", source, url }, {}, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				return
			end
			settle(source, target, function(bytes)
				data(bytes)
			end)
		end)
	end)

	return data
end

return M
