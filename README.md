<div align="center">

🚨 **leetcode.nvim is currently in the _alpha stage_ of development** 🚨

______________________________________________________________________

# leetcode.nvim

🔥 Solve [LeetCode] problems within [Neovim] 🔥

</div>

https://github.com/kawre/leetcode.nvim/assets/69250723/309088c9-4ff7-4dff-ab61-ab3f09b43740

## ✨ Features

- 📌 an intuitive dashboard for effortless navigation within [leetcode.nvim]

- 😍 question description formatting for a better readability

- 📈 [LeetCode] profile statistics within [Neovim] (Soon)

- 🔀 support for daily and random questions

- 💾 caching for optimized performance

## 📬 Requirements

- [Neovim] >= 0.9.0

- [telescope.nvim]

- [nui.nvim]

- [nvim-treesitter] _**(optional, but highly recommended)**_
  used for formatting the question description.
  Make sure to install the parser for `html`.

- [nvim-notify] _**(optional)**_

- [Nerd Font][nerd-font] & [nvim-web-devicons] _**(optional)**_

## 📦 Installation

- [lazy.nvim]

```lua
{
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim", -- required by telescope
        "MunifTanjim/nui.nvim",

        -- optional
        "rcarriga/nvim-notify",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        -- configuration goes here
    },
}
```

<!-- [packer.nvim]: https://github.com/wbthomason/packer.nvim -->

## 🛠️ Configuration

To see full configuration types see [template.lua](./lua/leetcode/config/template.lua)

### ⚙️ default configuration

<!-- <details> -->

<!--   <summary>Click to see</summary> -->

```lua
{
    ---@type lc.domain
    domain = "com", -- For now "com" is the only one supported

    ---@type string
    arg = "leetcode.nvim",

    ---@type lc.lang
    lang = "cpp",

    ---@type lc.sql
    sql = "mysql",

    ---@type string
    directory = vim.fn.stdpath("data") .. "/leetcode/",

    ---@type boolean
    logging = true,

    console = {
        open_on_runcode = false, ---@type boolean

        dir = "row", ---@type "col" | "row"

        size = {
            width = "90%", ---@type string | integer
            height = "75%", ---@type string | integer
        },

        result = {
            size = "60%", ---@type string | integer
        },

        testcase = {
            virt_text = true, ---@type boolean

            size = "40%", ---@type string | integer
        },
    },

    description = {
        position = "left", ---@type "top" | "right" | "bottom" | "left"

        width = "40%", ---@type string | integer
    },
}
```

<!-- </details> -->

### arg

Argument for [Neovim]

```lua
---@type string
arg = "leetcode.nvim"
```

<small>See [usage](#-usage) for more info</small>

### lang

Language to start your session with

```lua
---@type lc.lang
lang = "cpp"

---@type lc.sql_lang
sql = "mysql"
```

### domain

[LeetCode] domain.

```lua
---@type lc.domain
domain = "com" -- For now "com" is the only one supported
```

### directory

Where to store [leetcode.nvim] data

```lua
---@type string
directory = vim.fn.stdpath("data") .. "/leetcode/"
```

### logging

Whether to log [leetcode.nvim] status notifications

```lua
---@type boolean
logging = true
```

## 📋 Commands

| command             | description                                                   |
| ------------------- | ------------------------------------------------------------- |
| LcMenu              | opens menu dashboard                                          |
| LcList              | opens a problem list picker                                   |
| LcConsole           | opens console pop-up for currently opened question            |
| LcHints             | opens hints pop-up for currently opened question              |
| LcTabs              | opens a picker with all currently opened question tabs        |
| LcLanguage          | opens a picker to change the language of the current question |
| LcDescriptionToggle | toggle question description                                   |
| LcRun               | run currently opened question                                 |
| LcSubmit            | submit currently opened question                              |

## 🚀 Usage

This plugin is meant to be used within a **fresh** [Neovim] instance.
Meaning that to launch [leetcode.nvim] you **have** to pass
[`arg`](#arg) as the _first and **only**_ [Neovim] argument

```
nvim leetcode.nvim
```

### Sign In

It is **required** to be **signed-in** to use [leetcode.nvim]

https://github.com/kawre/leetcode.nvim/assets/69250723/b7be8b95-5e2c-4153-8845-4ad3abeda5c3

## 🍴 Recipes

### lazy loading

- proper lazy loading with [lazy.nvim]

```lua
local leet_arg = "leetcode.nvim"

return {
    "kawre/leetcode.nvim",
    lazy = leet_arg ~= vim.fn.argv()[1],
    opts = {
        arg = leet_arg,
    },
}
```

## ✅ Todo

- \[ \] CN version
- \[ \] SQL support
- \[ \] Statistics menu page
- \[ \] Docs
- \[x\] Hints pop-up

## 🙌 Credits

- [Leetbuddy.nvim](https://github.com/Dhanus3133/Leetbuddy.nvim)

- [alpha-nvim](https://github.com/goolord/alpha-nvim)

[lazy.nvim]: https://github.com/folke/lazy.nvim
[leetcode]: https://leetcode.com
[leetcode.nvim]: https://github.com/kawre/leetcode.nvim
[neovim]: https://github.com/neovim/neovim
[nerd-font]: https://www.nerdfonts.com
[nui.nvim]: https://github.com/MunifTanjim/nui.nvim
[nvim-notify]: https://github.com/rcarriga/nvim-notify
[nvim-treesitter]: https://github.com/nvim-treesitter/nvim-treesitter
[nvim-web-devicons]: https://github.com/nvim-tree/nvim-web-devicons
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
