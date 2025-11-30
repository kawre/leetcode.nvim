---@class lc.ProblemLists
local ProblemLists = {}

-- Section mapping for Blind75
local blind75_sections = {
    ["arrays-hashing"] = {
        "contains-duplicate",
        "valid-anagram",
        "two-sum",
        "group-anagrams",
        "top-k-frequent-elements",
        "encode-and-decode-strings",
        "product-of-array-except-self",
        "longest-consecutive-sequence",
    },
    ["two-pointers"] = {
        "valid-palindrome",
        "3sum",
        "container-with-most-water",
    },
    ["sliding-window"] = {
        "best-time-to-buy-and-sell-stock",
        "longest-substring-without-repeating-characters",
        "longest-repeating-character-replacement",
        "minimum-window-substring",
    },
    ["stack"] = {
        "valid-parentheses",
    },
    ["binary-search"] = {
        "find-minimum-in-rotated-sorted-array",
        "search-in-rotated-sorted-array",
    },
    ["linked-list"] = {
        "reverse-linked-list",
        "merge-two-sorted-lists",
        "linked-list-cycle",
        "reorder-list",
        "remove-nth-node-from-end-of-list",
        "merge-k-sorted-lists",
    },
    ["trees"] = {
        "invert-binary-tree",
        "maximum-depth-of-binary-tree",
        "same-tree",
        "subtree-of-another-tree",
        "lowest-common-ancestor-of-a-binary-search-tree",
        "binary-tree-level-order-traversal",
        "validate-binary-search-tree",
        "kth-smallest-element-in-a-bst",
        "construct-binary-tree-from-preorder-and-inorder-traversal",
        "binary-tree-maximum-path-sum",
        "serialize-and-deserialize-binary-tree",
    },
    ["heap"] = {
        "find-median-from-data-stream",
    },
    ["backtracking"] = {
        "combination-sum",
        "word-search",
    },
    ["tries"] = {
        "implement-trie-prefix-tree",
        "design-add-and-search-words-data-structure",
        "word-search-ii",
    },
    ["graphs"] = {
        "number-of-islands",
        "clone-graph",
        "pacific-atlantic-water-flow",
        "course-schedule",
        "graph-valid-tree",
        "number-of-connected-components-in-an-undirected-graph",
    },
    ["advanced-graphs"] = {
        "alien-dictionary",
    },
    ["1d-dp"] = {
        "climbing-stairs",
        "house-robber",
        "house-robber-ii",
        "longest-palindromic-substring",
        "palindromic-substrings",
        "decode-ways",
        "coin-change",
        "maximum-product-subarray",
        "word-break",
        "longest-increasing-subsequence",
    },
    ["2d-dp"] = {
        "unique-paths",
        "longest-common-subsequence",
    },
    ["greedy"] = {
        "maximum-subarray",
        "jump-game",
    },
    ["intervals"] = {
        "insert-interval",
        "merge-intervals",
        "non-overlapping-intervals",
        "meeting-rooms",
        "meeting-rooms-ii",
    },
    ["math-geometry"] = {
        "rotate-image",
        "spiral-matrix",
        "set-matrix-zeroes",
    },
    ["bit-manipulation"] = {
        "number-of-1-bits",
        "counting-bits",
        "reverse-bits",
        "missing-number",
        "sum-of-two-integers",
    },
}

---Get problems for a specific Blind75 section
---@param section_key string
---@return string[]
function ProblemLists.get_blind75_section(section_key)
    return blind75_sections[section_key] or {}
end

return ProblemLists

