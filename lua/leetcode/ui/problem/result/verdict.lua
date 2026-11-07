local m = require("markup")
local kit = require("leetcode.ui.kit")

local animate = Markup.animate

local SHAKE_CELLS = 2

--- The band every result opens with. It flashes in, and shakes on failures.
---@param props { title: string, kind: "ok"|"error"|"warn", detail?: any, icon?: string }
return m.component(function(props)
	local group = "leetcode_verdict_" .. props.kind
	local band = kit.color(group, "bg")
	local bright = kit.color(group, "fg")

	local style = animate.enabled
			and animate.highlight({ bg = bright }, { bg = band }, {
				duration = 310,
				easing = "out_quad",
				base = vim.api.nvim_get_hl(0, { name = group, link = false }),
				link = group,
			})
		or group

	local shake = m.signal(0)
	if props.kind ~= "ok" then
		animate.run({
			duration = 270,
			easing = "linear",
			update = function(t)
				shake(math.sin(t * math.pi * 6) * (1 - t) * SHAKE_CELLS)
			end,
		})
	end

	return m.flex({
		style = style,
		border = "half",
		justify = "between",
		padding = { 0, 2 },
		margin_bottom = 1,
		white_space = "nowrap",
		m.inline({
			margin_left = function()
				return SHAKE_CELLS + math.floor(shake() + 0.5)
			end,
			m.inline((props.icon or (props.kind == "ok" and kit.icons.check or kit.icons.cross)) .. "  "),
			m.inline(props.title),
		}),
		props.detail,
	})
end)
