local config = require("leetcode.config")

local arguments = {}

local topics = {
    "dynamic-programming",
    "math",
    "hash-table",
    "string",
    "array",
    "biconnected-component",
    "eulerian-circuit",
    "radix-sort",
    "rejection-sampling",
    "strongly-connected-component",
    "reservoir-sampling",
    "minimum-spanning-tree",
    "counting-sort",
    "line-sweep",
    "shell",
    "suffix-array",
    "bucket-sort",
    "quickselect",
    "concurrency",
    "doubly-linked-list",
    "probability-and-statistics",
    "iterator",
    "merge-sort",
    "monotonic-queue",
    "randomized",
    "string-matching",
    "data-stream",
    "rolling-hash",
    "brainteaser",
    "interactive",
    "combinatorics",
    "shortest-path",
    "hash-function",
    "topological-sort",
    "binary-indexed-tree",
    "game-theory",
    "geometry",
    "segment-tree",
    "memoization",
    "binary-search-tree",
    "divide-and-conquer",
    "number-theory",
    "bitmask",
    "queue",
    "recursion",
    "trie",
    "monotonic-stack",
    "enumeration",
    "sliding-window",
    "union-find",
    "linked-list",
    "backtracking",
    "counting",
    "design",
    "simulation",
    "heap-priority-queue",
    "two-pointers",
    "database",
    "sorting",
    "greedy",
    "breadth-first-search",
    "depth-first-search",
    "bit-manipulation",
    "binary-tree",
    "matrix",
    "tree",
    "graph",
    "prefix-sum",
    "stack",
    "ordered-set",
    "binary-search",
}

arguments.list = {
    difficulty = { "easy", "medium", "hard" },
    status = { "ac", "notac", "todo" },
}

arguments.random = {
    difficulty = { "easy", "medium", "hard" },
    status = { "ac", "notac", "todo" },
    tags = topics,
}

arguments.session_change = setmetatable({}, {
    __index = function(_, key)
        if key == "name" then
            local sessions = config.sessions
            return vim.tbl_map(function(s) return s.name end, sessions)
        end
    end,
})

arguments.session_create = {
    name = {},
}

return arguments
