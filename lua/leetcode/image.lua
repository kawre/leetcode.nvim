--- Images of problem descriptions, downloaded once and kept as PNG, which is
--- what Neovim can show. Other formats are converted with whatever is there,
--- and a GIF into a PNG for each of its frames, which play in a loop.

local m = require("markup")
local config = require("leetcode.config")

---@class leet.image
local M = {}

local loading = {} ---@type table<string, fun(): string?>

local PNG_SIGNATURE = "\137PNG\r\n\26\n"
local GIF_SIGNATURE = "GIF8"

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

--- ImageMagick's commands, to split a GIF into its frames and read how long
--- each shows, or nothing without it.
---@return { convert: string[], identify: string[] }?
function M.magick()
	if vim.fn.executable("magick") == 1 then
		return { convert = { "magick" }, identify = { "magick", "identify" } }
	elseif vim.fn.executable("convert") == 1 and vim.fn.executable("identify") == 1 then
		return { convert = { "convert" }, identify = { "identify" } }
	end
end

--- The frames of a GIF split before, as `m.image` plays them.
---@param dir string
---@return markup.image.frame[]?
local function read_frames(dir)
	local delays = read(vim.fs.joinpath(dir, "delays"))
	if not delays then
		return nil
	end
	local frames = {}
	for line in delays:gmatch("[^\n]+") do
		local data = read(vim.fs.joinpath(dir, ("%04d.png"):format(#frames)))
		if not data then
			return nil
		end
		-- GIFs count in hundredths of a second, and browsers show a delay of 0
		-- as a tenth.
		local hundredths = tonumber(line) or 0
		frames[#frames + 1] = { data = data, delay = (hundredths > 1 and hundredths or 10) * 10 }
	end
	return #frames > 0 and frames or nil
end

--- Splits the GIF at `source` into PNG frames in `dir`, then calls `done` with
--- them, or with nil when that cannot be done.
local function split_gif(source, dir, done)
	local magick = M.magick()
	if not magick then
		return done(nil)
	end
	vim.fn.mkdir(dir, "p")

	local identify = vim.list_extend(vim.deepcopy(magick.identify), { "-format", "%T\n", source })
	vim.system(identify, { text = true }, function(timing)
		local convert = vim.list_extend(vim.deepcopy(magick.convert), {
			source,
			"-coalesce",
			vim.fs.joinpath(dir, "%04d.png"),
		})
		vim.system(convert, {}, function(result)
			vim.schedule(function()
				if timing.code ~= 0 or result.code ~= 0 then
					vim.fn.delete(dir, "rf")
					return done(nil)
				end
				-- Written last, so a split cut short is never read as a whole one.
				vim.fn.writefile(vim.split(vim.trim(timing.stdout or ""), "\n"), vim.fs.joinpath(dir, "delays"))
				done(read_frames(dir))
			end)
		end)
	end)
end

--- Makes `source` a PNG at `target`, or the frames of a GIF next to it, then
--- calls `done` with them.
local function settle(source, target, done)
	local head = read(source) or ""
	if head:sub(1, 8) == PNG_SIGNATURE then
		vim.uv.fs_rename(source, target)
		return done(read(target))
	end

	if head:sub(1, 4) == GIF_SIGNATURE and M.magick() then
		return split_gif(source, M.frames_dir(target), function(frames)
			if frames then
				os.remove(source)
				return done(frames)
			end
			-- Its first frame, as a still image, rather than nothing.
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
		end)
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

---@param target string
---@return string
function M.frames_dir(target)
	return (target:gsub("%.png$", ".frames"))
end

--- The bytes of an image as a PNG, or the frames of a GIF, once they are there.
---@param url string
---@return fun(): (string|markup.image.frame[])?
function M.load(url)
	if loading[url] then
		return loading[url]
	end

	local data = m.signal(nil)
	loading[url] = data

	vim.fn.mkdir(dir(), "p")
	local target = vim.fs.joinpath(dir(), vim.fn.sha256(url) .. ".png")
	local frames = read_frames(M.frames_dir(target))
	if frames then
		data(frames)
		return data
	end
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
