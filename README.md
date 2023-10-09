<div align="center">

🚨 <b>leetcode.nvim is currently in the <i>alpha stage</i> of development</b> 🚨

---

# leetcode.nvim

🔥 Solve [LeetCode] problems within [Neovim] 🔥

</div>

https://github.com/kawre/leetcode.nvim/assets/69250723/309088c9-4ff7-4dff-ab61-ab3f09b43740

[leetcode.nvim]: https://github.com/kawre/leetcode.nvim
[LeetCode]: https://leetcode.com
[Neovim]: https://github.com/neovim/neovim

## ✨ Features

- 📌 an intuitive dashboard for effortless navigation within [leetcode.nvim]

- 😍 question description formatting for a better readability

- 📈 [LeetCode] profile statistics within [Neovim] (Soon)

- 🔀 support for daily and random questions

- 💾 caching for optimized performance

## 📬 Requirements

- [Neovim]

- [nvim-treesitter][nvim-treesitter]

- [telescope.nvim][telescope.nvim]

- [nui.nvim][nui.nvim]

[nvim-treesitter]: https://github.com/nvim-treesitter/nvim-treesitter
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
[nui.nvim]: https://github.com/MunifTanjim/nui.nvim
[nvim-notify]: https://github.com/rcarriga/nvim-notify

## 📦 Installation

- [lazy.nvim][lazy.nvim]

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
        "nvim-tree/nvim-web-devicons",

        -- recommended
        -- "rcarriga/nvim-notify",
    },
    opts = {
        -- configuration goes here
    },
}
```

[lazy.nvim]: https://github.com/folke/lazy.nvim
[packer.nvim]: https://github.com/wbthomason/packer.nvim

## 🛠️ Configuration

To see full configuration types see [template.lua](./lua/leetcode/config/template.lua)

### ⚙️ default configuration

<details>
  <summary>Click to see</summary>

```lua
{
    ---@type lc.domain
    domain = "com", -- For now "com" is the only one supported

    ---@type string
    arg = "leetcode.nvim",

    ---@type lc.lang
    lang = "cpp",

    ---@type lc.sql_lang
    sql = "mysql",

    ---@type string
    directory = vim.fn.stdpath("data") .. "/leetcode/",

    ---@type boolean
    logging = true,

    console = {
        size = {
            width = "75%", ---@type string | integer
            height = "75%", ---@type string | integer
        },
        dir = "row", ---@type "col" | "row"
    },

    description = {
        width = "40%", ---@type string | integer
    },
}

```

</details>

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

Where to store [leetcode.nvim][leetcode.nvim] data

```lua
---@type string
directory = vim.fn.stdpath("data") .. "/leetcode/"
```

### logging

Whether to log [leetcode.nvim][leetcode.nvim] status notifications

```lua
---@type boolean
logging = true
```

### console

Console appearance

```lua
console = {
    size = {
        width = "75%", ---@type string | integer
        height = "75%", ---@type string | integer
    },
    dir = "row", ---@type "col" | "row"
}
```

### description

Question description appearance

```lua
description = {
    width = "40%", ---@type string | integer
}
```

## 📋 Commands

| command             | description                                                 |
| ------------------- | ----------------------------------------------------------- |
| LcList              | opens a problem list picker                                 |
| LcMenu              | opens menu dashboard                                        |
| LcConsole           | opens console for currently opened question                 |
| LcQuestionTabs      | opens a picker with all currently opened question tabs      |
| LcLanguage          | opens a picker to select a language for the current session |
| LcDescriptionToggle | toggle question description                                 |
| LcRun               | run currently opened question                               |
| LcSubmit            | submit currently opened question                            |

## 🚀 Usage

This plugin is meant to be used within a <b>fresh</b> [Neovim] instance.
Meaning that to lauch [leetcode.nvim][leetcode.nvim] you <b>have</b> to pass [`arg`](#arg) as the <i>first and <b>only</b></i> [Neovim] argument

```
nvim leetcode.nvim
```

### Sign In

It is <b>required</b> to be <b>signed-in</b> to use [leetcode.nvim][leetcode.nvim]

https://github.com/kawre/leetcode.nvim/assets/69250723/b7be8b95-5e2c-4153-8845-4ad3abeda5c3

<!-- ## 🍴 Recipes -->
<!---->
<!-- - Full lazy loading with [lazy.nvim] -->
<!---->
<!-- ```lua -->
<!-- local usr_arg = "leetcode.nvim" -->
<!---->
<!-- { -->
<!--     "kawre/leetcode.nvim", -->
<!--     ... -->
<!--     opts = { ..., arg = usr_arg, ... }, -->
<!--     cond = function() return usr_arg == vim.fn.argv()[1] end, -->
<!--     ... -->
<!-- } -->
<!-- ``` -->

### Working with multiple questions

When you open a new <b>question</b>, [leetcode.nvim] creates a new [tabpage] <i>containing
all of the <b>contents</b> related to it</i>.
To switch between these tabs, use [LcQuestionTabs](#📋-commands) command

https://github.com/kawre/leetcode.nvim/assets/69250723/64378b0f-c5ba-4378-b9ff-a95df13fbf36

[tabpage]: https://neovim.io/doc/user/tabpage.html

## ✅ Todo

- [ ] CN version
- [ ] SQL support
- [ ] Statistics menu page
- [ ] Docs
- [ ] Hints pop-up

## 🙌 Credits

- [Leetbuddy.nvim](https://github.com/Dhanus3133/Leetbuddy.nvim)

- [alpha-nvim](https://github.com/goolord/alpha-nvim)
