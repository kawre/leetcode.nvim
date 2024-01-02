<div align="center">

🚨 **leetcode.nvim 目前处于 _alpha 阶段_ 开发中** 🚨

______________________________________________________________________

# leetcode.nvim

🔥 在 [Neovim] 中解决 [LeetCode] 问题 🔥

🇺🇸 <a href="README.md">English</a>, 🇨🇳 简体中文

</div>

https://github.com/kawre/leetcode.nvim/assets/69250723/aee6584c-e099-4409-b114-123cb32b7563

## ✨ 特性

- 📌 直观的仪表板，轻松导航 [leetcode.nvim] 内

- 😍 更好的可读性的问题描述格式

- 📈 在 [Neovim] 中显示 [LeetCode] 个人统计信息

- 🔀 支持每日和随机问题

- 💾 缓存以优化性能

## 📬 环境要求

- [Neovim] >= 0.9.0

- [telescope.nvim]

- [nui.nvim]

- [nvim-treesitter] _**(可选，但强烈推荐)**_
  用于格式化问题描述。
  确保安装 `html` 解析器。

- [nvim-notify] _**(可选)**_

- [Nerd Font][nerd-font] & [nvim-web-devicons] _**(可选)**_

## 📦 安装

- [lazy.nvim]

```lua
{
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim", -- telescope 所需
        "MunifTanjim/nui.nvim",

        -- 可选
        "nvim-treesitter/nvim-treesitter",
        "rcarriga/nvim-notify",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        -- 配置放在这里
        cn = {
            enabled = true,
        },
    },
}
```

## 🛠️ 配置

要查看完整的配置类型，请参见 [template.lua](./lua/leetcode/config/template.lua)

### ⚙️  默认配置

<!-- <details> -->

<!--   <summary>Click to see</summary> -->

```lua
{
    ---@type string
    arg = "leetcode.nvim",

    ---@type lc.lang
    lang = "cpp",

    cn = { -- leetcode.cn
        enabled = false, ---@type boolean
        translator = true, ---@type boolean
        translate_problems = true, ---@type boolean
    },

    ---@type string
    directory = vim.fn.stdpath("data") .. "/leetcode/",

    ---@type boolean
    logging = true,

    injector = {} ---@type table<lc.lang, lc.inject>

    cache = {
        update_interval = 60 * 60 * 24 * 7, ---@type integer 7 days
    },

    console = {
        open_on_runcode = true, ---@type boolean

        dir = "row", ---@type lc.direction

        size = { ---@type lc.size
            width = "90%",
            height = "75%",
        },

        result = {
            size = "60%", ---@type lc.size
        },

        testcase = {
            virt_text = true, ---@type boolean

            size = "40%", ---@type lc.size
        },
    },

    description = {
        position = "left", ---@type lc.position

        width = "40%", ---@type lc.size

        show_stats = true, ---@type boolean
    },

    hooks = {
        ---@type fun()[]
        LeetEnter = {},

        ---@type fun(question: { lang: string })[]
        LeetQuestionNew = {},
    },

    ---@type boolean
    image_support = false, -- setting this to `true` will disable question description wrap

    keys = {
        toggle = { "q", "<Esc>" }, ---@type string|string[]
        confirm = { "<CR>" }, ---@type string|string[]

        reset_testcases = "r", ---@type string
        use_testcase = "U", ---@type string
        focus_testcases = "H", ---@type string
        focus_result = "L", ---@type string
    },
}
```

### arg

[Neovim] 的参数

```lua
---@type string
arg = "leetcode.nvim"
```

<small>有关更多信息，请参见 [usage](#-usage)</small>

### lang

会话开始时使用的语言

```lua
---@type lc.lang
lang = "cpp"
```

### cn

将 [leetcode.com][leetcode] 替换为 [leetcode.cn]

```lua
cn = { -- leetcode.cn
    enabled = false, ---@type boolean
    translator = true, ---@type boolean
    translate_problems = true, ---@type boolean
},
```

### directory

存储 [leetcode.nvim] 数据的位置

```lua
---@type string
directory = vim.fn.stdpath("data") .. "/leetcode/"
```

### logging

是否记录 [leetcode.nvim] 状态通知

```lua
---@type boolean
logging = true
```

### injector

在你的答案前后注入额外代码，注入的代码不会被提交或测试。

```lua
injector = { ---@type table<lc.lang, lc.inject>
    ["cpp"] = {
        before = { "#include <bits/stdc++.h>", "using namespace std;" },
        after = "int main() {}",
    },
    ["java"] = {
        before = "import java.util.*;",
    },
}
```

### hooks

在指定事件上执行的函数列表

```lua
hooks = {
    ---@type fun()[]
    LeetEnter = {},

    ---@type fun(question: lc.ui.Question)[]
    LeetQuestionNew = {},
},
```

### image support

是否使用 [image.nvim] 渲染问题描述中的图片

```lua
---@type boolean
image_support = false, -- 将此设置为 `true` 将禁用问题描述的换行
```

## 📋 命令

### `Leet` 打开菜单仪表板

- `menu` 与 `Leet` 相同

- `console` 打开当前打开问题的控制台弹出窗口

- `info` 打开包含当前打开问题信息的弹出窗口

- `tabs` 打开所有当前打开问题选项卡的选择器

- `lang` 打开更改当前问题语言的选择器

- `run` 运行当前打开的问题

- `test` 与 `Leet run` 相同

- `submit` 提交当前打开的问题

- `random` 打开一个随机问题

- `daily` 打开今天的问题

- [`list`](#leet-list) 打开问题列表选择器

- `desc` 切换问题描述

  - `toggle` 与 `Leet desc` 相同

  - `stats` 切换描述统计可见性

- `cookie`

  - `update` 打开提示输入新 cookie

  - `delete` 注销

- `cache`

  - `update` 更新缓存

#### `Leet list`

可以带有可选参数。要堆叠参数值，请使用 , 将它们分隔开

```
Leet list status=<status> difficulty=<difficulty>
```

## 🚀 使用方法

此插件应该在 **全新** 的 [Neovim] 实例中使用。
这意味着要启动 [leetcode.nvim]，您 **必须** 将
[`arg`](#arg) 作为 _第一个且 **唯一**_ [Neovim] 参数

```
nvim leetcode.nvim
```

### 切换问题

要在问题之间切换，请使用 `Leet tabs`。

### 登录

使用 [leetcode.nvim] 必须 **登录**

https://github.com/kawre/leetcode.nvim/assets/69250723/b7be8b95-5e2c-4153-8845-4ad3abeda5c3

## 🍴 示例

### 懒加载

- 使用 [lazy.nvim] 实现正确的懒加载

```lua
local leet_arg = "leetcode.nvim"

return {
    "kawre/leetcode.nvim",
    ...
    lazy = leet_arg ~= vim.fn.argv()[1],
    opts = {
        arg = leet_arg,
    },
    ...
}
```

## ✅ 待办事项

- \[x\] 中文版本
- \[x\] 统计菜单页面
- \[ \] 文档
- \[x\] 提示弹出窗口

## 🙌 鸣谢

- [Leetbuddy.nvim](https://github.com/Dhanus3133/Leetbuddy.nvim)

- [alpha-nvim](https://github.com/goolord/alpha-nvim)

[image.nvim]: https://github.com/3rd/image.nvim
[lazy.nvim]: https://github.com/folke/lazy.nvim
[leetcode]: https://leetcode.com
[leetcode.cn]: https://leetcode.cn
[leetcode.nvim]: https://github.com/kawre/leetcode.nvim
[neovim]: https://github.com/neovim/neovim
[nerd-font]: https://www.nerdfonts.com
[nui.nvim]: https://github.com/MunifTanjim/nui.nvim
[nvim-notify]: https://github.com/rcarriga/nvim-notify
[nvim-treesitter]: https://github.com/nvim-treesitter/nvim-treesitter
[nvim-web-devicons]: https://github.com/nvim-tree/nvim-web-devicons
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
