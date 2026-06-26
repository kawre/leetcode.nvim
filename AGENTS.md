# AGENTS.md

Agent map for `leetcode.nvim`.

Read ADRs first when changing session behavior, hooks, or the CodeCompanion bridge. Use `README.md` and nearby Lua modules after that.

## What This Repo Owns

- LeetCode UI, commands, and question lifecycle inside Neovim
- hook dispatch around test / submit / timer events
- CodeCompanion bridge for LeetCode context injection
- editor-side rendering for submission-service-backed companion events

## Start Here

1. [docs/adrs/001-codecompanion-session-failure-event-bridge.md](./docs/adrs/001-codecompanion-session-failure-event-bridge.md)
2. [README.md](./README.md)
3. [lua/leetcode/integrations/codecompanion.lua](./lua/leetcode/integrations/codecompanion.lua)
4. [lua/leetcode/config/hooks.lua](./lua/leetcode/config/hooks.lua)
5. [lua/leetcode/runner/init.lua](./lua/leetcode/runner/init.lua)

## File Map

- `lua/leetcode/integrations/codecompanion.lua`
  CodeCompanion bridge, hidden context injection, question-bound chat tracking, failure-event rendering.
- `lua/leetcode/config/hooks.lua`
  Canonical hook registration and defaults.
- `lua/leetcode/runner/init.lua`
  Execution path for test / submit flows and hook dispatch.
- `lua/leetcode/command/init.lua`
  User-facing `:Leet` commands.
- `lua/leetcode-ui/`
  Question, result, and side-panel rendering.
- `docs/adrs/`
  Durable behavior decisions for this fork.

## Guardrails

- Keep `leetcode.nvim` as a UI/context bridge; do not move provider or model ownership into this repo.
- Prefer stable data from submission service over reconstructing session truth inside Lua.
- Keep hook payload shapes backward compatible unless the user explicitly asks for a contract change.
- Prefer hidden context for companion-side lifecycle metadata over visible user-message injection.

## D2 Diagram Style Preference

When adding or updating D2 diagrams, prefer the user's established high-level architecture style:

- Treat D2 as a system overview first, not an implementation-detail dump.
- Group nodes by runtime boundary before drawing flows, for example `Strict local`.
- Clearly separate entry points, runtime surfaces, external systems, and data planes.
- Prefer a left-to-right primary reading direction with straight main flows and minimal crossing lines.
- Optimize for ownership and data flow clarity, not source-file completeness.
- Use a small number of stable responsibility-oriented node labels rather than many file/module names.
- Keep edge labels short and protocol/action-oriented, such as `JSON over TCP`.
- Preserve generous whitespace and a clean overview feel; prefer one readable system map plus optional focused sub-diagrams.

## When To Update Docs

- Update ADRs when the companion bridge, session binding, or hook semantics change.
- Update `README.md` when user-facing setup or behavior changes.
- Update this file only when the navigation order or edit guardrails change.
