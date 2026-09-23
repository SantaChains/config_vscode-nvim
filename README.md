# config_vscode-nvim

双配置 nvim 仓库：根目录 init.lua 是 vscode-neovim 专用极简配置，nvim/ 子目录是完整 LazyVim 独立配置。

## 目录结构

```
config_vscode-nvim/
├── init.lua              # vscode-neovim 专用配置（NVIM_APPNAME=vscode-nvim 加载）
├── lazy-lock.json        # 根目录插件版本锁定
├── .vscode/
│   ├── settings.json     # VSCode 扩展配置（NVIM_APPNAME、ctrlKeys、compositeKeys）
│   └── keybindings.json  # 抑制与 nvim 冲突的 VSCode 快捷键
├── .gitignore
├── README.md
└── nvim/                 # 完整 LazyVim 独立配置（可直接 nvim 运行）
    ├── init.lua
    ├── lazy-lock.json
    ├── lazyvim.json
    ├── lua/
    │   ├── config/       # LazyVim 配置（keymaps/options/autocmds/lazy）
    │   ├── plugins/      # 插件定义（ui/editor/coding/lsp）
    │   ├── plugins/lang/ # 语言配置（bash/lua/powershell）
    │   └── util/         # 工具函数
    ├── LICENSE           # Apache 2.0，派生自 mrbeardad/nvim
    └── stylua.toml
```

## 两套配置的定位

### 根目录 init.lua — vscode-neovim 极简版

通过 `NVIM_APPNAME=vscode-nvim` 被 vscode-neovim 加载。性能优先，VSCode 负责 LSP/UI/语法高亮，nvim 侧零 treesitter/Mason/LSP 开销。插件极简：

| 插件                                                                                  | 用途                       |
|---------------------------------------------------------------------------------------|----------------------------|
| [nvim-surround](https://github.com/kylechui/nvim-surround)                            | 包围符号增删改（ys/ds/cs） |
| [flash.nvim](https://github.com/folke/flash.nvim)                                     | 双字符跳转（s/S/f/F/t/T）  |
| [hop.nvim](https://github.com/smoka7/hop.nvim)                                        | EasyMotion 全局跳转        |
| [vscode-multi-cursor.nvim](https://github.com/vscode-neovim/vscode-multi-cursor.nvim) | visual 转 VSCode 多光标    |

### nvim/ — 完整 LazyVim 独立版

基于 LazyVim 8，可直接 `nvim` 命令运行。含完整的 treesitter、Mason、LSP、Snacks 文件管理/终端/选择器、mini 系列增强、yanky 历史、blink.cmp 补全、multi-cursor 等组件。通过 `vim.g.vscode` guard 同时兼容 vscode-neovim 环境。

## 安装

### 1. Clone

Windows:

```powershell
git clone https://github.com/SantaChains/config_vscode-nvim $env:USERPROFILE\.config\vscode-nvim
```

Linux/macOS:

```bash
git clone https://github.com/SantaChains/config_vscode-nvim ~/.config/vscode-nvim
```

### 2. vscode-neovim 扩展配置

仓库内已包含 `.vscode/settings.json` 模板，将以下配置复制到你的 VSCode 用户 settings.json：

```json
{
  "extensions.experimental.affinity": {
    "vscode-neovim.vscode-neovim": 1
  },

  "vscode-neovim.neovimExecutablePaths.win32": "nvim",
  "vscode-neovim.neovimExecutablePaths.linux": "nvim",
  "vscode-neovim.neovimExecutablePaths.darwin": "nvim",

  "vscode-neovim.NVIM_APPNAME": "vscode-nvim",

  "vscode-neovim.ctrlKeysForInsertMode": [
    "w", "a", "e", "o", "h", "u", "d", "k", "r", "n"
  ],
  "vscode-neovim.ctrlKeysForNormalMode": [
    "w", "d", "u", "b", "o", "i", "a", "x", "v", "r", "j", "n"
  ],

  "vscode-neovim.compositeKeys": {
    "jj": {
      "cmd": "vscode-neovim.escape",
      "keys": [
        {
          "key": "j",
          "when": "editorTextFocus && neovim.mode == insert"
        }
      ]
    }
  },

  "vscode-neovim.logOutputToConsole": false
}
```

NVIM_APPNAME 让 vscode-neovim 加载 `~/.config/vscode-nvim/init.lua`（根目录极简版）。插件数据写入 `%LOCALAPPDATA%\vscode-nvim-data`，独立于主 nvim 配置。

### 3. VSCode keybindings

仓库内 `.vscode/keybindings.json` 抑制与 nvim 冲突的 VSCode 快捷键（ctrl+tab、ctrl+s、ctrl+shift+e 等），同时补充 Ctrl+a/e 行首行尾、Ctrl+j 合并行、Ctrl+Shift+A 全选等映射。

### 4. 独立 nvim 运行（可选）

如需直接 `nvim` 命令运行完整配置，将 `nvim/` 目录内容复制/软链到 `~/.config/nvim/`：

```powershell
# Windows
Copy-Item -Recurse "$env:USERPROFILE\.config\vscode-nvim\nvim\*" "$env:LOCALAPPDATA\nvim\"
```

## 快捷键（根目录极简版）

`<Space>` 为 leader。

### Leader 键

| 快捷键      | VSCode action                            | 说明           |
|-------------|------------------------------------------|----------------|
| `leader ff` | workbench.action.quickOpen               | 快速打开文件   |
| `leader fw` | workbench.action.findInFiles             | 全局搜索       |
| `leader e`  | workbench.action.toggleSidebarVisibility | 切换侧边栏     |
| `leader p`  | workbench.action.showCommands            | 命令面板       |
| `leader w`  | workbench.action.files.save              | 保存           |
| `leader q`  | workbench.action.closeActiveEditor       | 关闭当前编辑器 |
| `leader bo` | workbench.action.closeOtherEditors       | 关闭其他编辑器 |
| `leader bl` | workbench.action.closeEditorsToTheLeft   | 关闭左侧编辑器 |
| `leader br` | workbench.action.closeEditorsToTheRight  | 关闭右侧编辑器 |

### LSP 跳转

| 快捷键 | VSCode action                    | 说明     |
|--------|----------------------------------|----------|
| `gy`   | editor.action.goToTypeDefinition | 类型定义 |
| `gr`   | editor.action.goToReferences     | 引用     |
| `gI`   | editor.action.goToImplementation | 实现     |

### 导航

| 快捷键    | VSCode action                    | 说明        |
|-----------|----------------------------------|-------------|
| `<C-o>`   | workbench.action.navigateBack    | 后退        |
| `<C-i>`   | workbench.action.navigateForward | 前进        |
| `H` / `L` | —                                | 行首 / 行尾 |

### Git 差异 & 诊断

| 快捷键      | 说明                       |
|-------------|----------------------------|
| `]h` / `[h` | 下一个 / 上一个 git 变更块 |
| `]d` / `[d` | 下一个 / 上一个诊断        |

### 跳转

| 快捷键                | 说明                               |
|-----------------------|------------------------------------|
| `s` / `S`             | flash 双字符跳转 / treesitter 跳转 |
| `f/F/t/T`             | flash 接管字符跳转                 |
| `leader leader w/j/f` | hop 全局词/行/字符跳转             |

### 多光标

| 快捷键 | 模式           | 说明                  |
|--------|----------------|-----------------------|
| `I`    | visual         | 每行起始加光标        |
| `A`    | visual         | 每行末尾加光标        |
| `c`    | visual (block) | 块模式下逐光标 change |

### 通用

| 快捷键             | 说明         |
|--------------------|--------------|
| `<` / `>` (visual) | 缩进保留选区 |
