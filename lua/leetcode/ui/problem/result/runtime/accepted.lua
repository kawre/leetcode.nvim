local m = require("markup")
local kit = require("leetcode.ui.kit")

local BAR_WIDTH = 30

local Metric = m.component(function(props)
	local percentile = tonumber(props.percentile)
	local beats = kit.counter(function()
		return percentile or 0
	end, { delay = props.delay })

	-- The cursor stops on the numbers only, not on what names them or the bar.
	return m.flex({
		white_space = "nowrap",
		m.inline({
			width = 11,
			snap = false,
			m.inline(props.icon .. " ", "leetcode_accent"),
			m.inline(props.label, "leetcode_muted"),
		}),
		m.inline({ width = 11, m.inline(props.value, "leetcode_strong") }),
		m.inline({
			snap = false,
			kit.Bar({
				width = BAR_WIDTH,
				delay = props.delay,
				style = "leetcode_bar_ok",
				value = function()
					return (percentile or 0) / 100
				end,
			}),
		}),
		percentile and m.inline({
			margin_left = 2,
			m.inline({ "beats ", style = "leetcode_muted", snap = false }),
			m.inline(function()
				return ("%.1f%%"):format(beats())
			end, "leetcode_ok"),
		}),
	})
end)

---@param props { item: lc.runtime }
local Accepted = m.component(function(props)
	local item = props.item
	local runtime_ms = item.display_runtime or vim.split(item.status_runtime, " ")[1] or "?"
	local memory = item.status_memory:gsub("(%d+)%s*(%a+)", "%1 %2")

	return m.vflex({
		spacing = 1,
		padding = { 0, 3 },
		Metric({
			icon = kit.icons.clock,
			label = "Runtime",
			value = runtime_ms .. " ms",
			percentile = item.runtime_percentile,
			delay = 200,
		}),
		Metric({
			icon = kit.icons.memory,
			label = "Memory",
			value = memory,
			percentile = item.memory_percentile,
			delay = 350,
		}),
	})
end)

return Accepted
