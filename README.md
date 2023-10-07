<div align="center">

# leetcode.nvim

Solve LeetCode problems within Neovim

</div>

[leetcode.nvim]: https://github.com/kawre/leetcode.nvim

## ✨ Features

- 📈 LeetCode statistics withing neovim (Soon)

- 🔀 Support for daily and random questions

- 💾 Problem list caching

## 📬 Dependencies

- [nvim-treesitter][nvim-treesitter]: html parser

- [telescope.nvim][telescope.nvim]: pickers

- [nui.nvim][nui.nvim]: ui provider

- [nvim-notify][nvim-notify]: notifications provider

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
      "MunifTanjim/nui.nvim",

      -- optional dependencies
      "rcarriga/nvim-notify",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      -- configuration goes here
    },
  }
  ```

[lazy.nvim]: https://github.com/folke/lazy.nvim
[packer.nvim]: https://github.com/wbthomason/packer.nvim

<h2 id="config">⚙️ Default Configuration</h2>

```lua
{
    ---@type string
    domain = "com",

    ---@type string
    arg = "leetcode.nvim",

    ---@type string
    lang = "java",

    ---@type
    ---| "pythondata"
    ---| "mysql"
    ---| "mssql"
    ---| "oraclesql"
    sql = "mysql",

    ---@type string
    directory = vim.fn.stdpath("data") .. "/leetcode/",

    ---@type boolean
    logging = true,

    menu_tabpage = 1,
    questions_tabpage = 2,

    console = {
        size = {
            width = "75%", ---@type string | integer
            height = "75%", ---@type string | integer
        },
        dir = "row", ---@type "col" | "row"

        result = {
            max_stdout_length = 200,
        },
    },

    description = {
        width = "40%", ---@type string | integer
    },
}
```

## 🚀 Usage

This plugin is meant to be used within a fresh neovim instance.
Meaning that to lauch [leetcode.nvim][leetcode.nvim] you have to pass [`arg`](#config) as the neovim argument

```
nvim leetcode.nvim
```

<!-- NOTE: [leetcode.nvim][leetcode.nvim] launch argument can be changed by modifying `arg` variable -->
<!-- inside [config](#config) -->

### Sign In

It is required to be signed-in to use [leetcode.nvim][leetcode.nvim]
