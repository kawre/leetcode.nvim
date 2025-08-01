local m = require("markup")

local function perc_hl(perc)
    if perc >= 50 then
        return "leetcode_ok"
    elseif perc >= 10 then
        return nil
    elseif perc >= 0 then
        return "leetcode_error"
    end
end

---@param props { item: lc.runtime }
local Accepted = m.component(function(props)
    local item = props.item
    local runtime_ms = item.display_runtime or vim.split(item.status_runtime, " ")[1] or "NIL"
    local lang = Leet.util.get_lang_by_name(item.pretty_lang)

    item.status_memory = item.status_memory:gsub("(%d+)%s*(%a+)", "%1 %2")
    local s_mem = vim.split(item.status_memory, " ")

    return m.block({
        m.block({
            m.inline("# Accepted "),
            lang.icon .. " " .. lang.lang,
            style = lang.hl or "Structure",
            margin_bottom = 1,
        }),
        m.flex({
            spacing = 3,
            m.block({
                m.block("  Runtime"),
                m.inline({
                    runtime_ms,
                    m.inline("ms", "Conceal"),
                }),
                " | ",
                m.inline(
                    ("%s %.2f%%"):format("Beats", item.runtime_percentile),
                    perc_hl(item.runtime_percentile)
                ),
            }),
            m.block({
                m.block("󰍛 Memory"),
                m.inline({
                    m.inline(s_mem, "Conceal"),
                }),
                " | ",
                m.inline({
                    "Beats ",
                    ("%.2f%%"):format(item.memory_percentile),
                    style = perc_hl(item.runtime_percentile),
                }),
            }),
        }),
    })
end)

return Accepted
