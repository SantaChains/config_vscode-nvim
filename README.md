# vscode-nvim

vscode-neovim 专用独立配置。性能优先，VSCode 负责 LSP/UI/语法高亮，nvim 侧只保留纯编辑增强。

## 设计原则

- 零启动开销：`syntax off`，不加载 treesitter、LSP、Mason、UI 组件
- 插件克制：4 个插件覆盖高频操作，全部 `VeryLazy`
- VSCode 集成：LSP 跳转、导航历史、git 差异、诊断全部路由到 VSCode action
- 独立隔离：NVIM_APPNAME=vscode-nvim 走独立 data 目录，不污染主 nvim 配置

## 插件

| 插件 | 用途 |
|------|------|
| [nvim-surround](https://github.com/kylechui/nvim-surround) | 包围符号增删改（ys/ds/cs） |
| [flash.nvim](https://github.com/folke/flash.nvim) | 双字符跳转替代（s/S） |
| [hop.nvim](https://github.com/smoka7/hop.nvim) | EasyMotion 替代（leader leader w/j/f） |
| [vscode-multi-cursor.nvim](https://github.com/vscode-neovim/vscode-multi-cursor.nvim) | visual 选区转 VSCode 多光标（I/A/c） |

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

### 2. VSCode settings.json

```json
{
  "vscode-neovim.neovimExecutablePaths.win32": "nvim",
  "vscode-neovim.neovimExecutablePaths.linux": "nvim",
  "vscode-neovim.neovimExecutablePaths.darwin": "nvim",
  "vscode-neovim.NVIM_APPNAME": "vscode-nvim"
}
```

NVIM_APPNAME 让 vscode-neovim 加载 `~/.config/vscode-nvim/init.lua`，插件数据写入独立目录。

## 快捷键

### Leader 键

`<Space>` 为 leader。

| 快捷键 | VSCode action | 说明 |
|--------|--------------|------|
| `leader ff` | workbench.action.quickOpen | 快速打开文件 |
| `leader fw` | workbench.action.findInFiles | 全局搜索 |
| `leader e` | workbench.action.toggleSidebarVisibility | 切换侧边栏 |
| `leader p` | workbench.action.showCommands | 命令面板 |
| `leader w` | workbench.action.files.save | 保存 |
| `leader q` | workbench.action.closeActiveEditor | 关闭当前编辑器 |
| `leader bo` | workbench.action.closeOtherEditors | 关闭其他编辑器 |
| `leader bl` | workbench.action.closeEditorsToTheLeft | 关闭左侧编辑器 |
| `leader br` | workbench.action.closeEditorsToTheRight | 关闭右侧编辑器 |

### LSP 跳转

| 快捷键 | VSCode action | 说明 |
|--------|--------------|------|
| `gy` | editor.action.goToTypeDefinition | 类型定义 |
| `gr` | editor.action.goToReferences | 引用 |
| `gI` | editor.action.goToImplementation | 实现 |

### 导航

| 快捷键 | VSCode action | 说明 |
|--------|--------------|------|
| `<C-o>` | workbench.action.navigateBack | 后退 |
| `<C-i>` | workbench.action.navigateForward | 前进 |
| `H` / `L` | — | 行首 / 行尾 |

### Git 差异 & 诊断

| 快捷键 | 说明 |
|--------|------|
| `]h` / `[h` | 下一个 / 上一个 git 变更块 |
| `]d` / `[d` | 下一个 / 上一个诊断 |

### 跳转（flash）

| 快捷键 | 说明 |
|--------|------|
| `s` | flash jump 双字符跳转 |
| `S` | flash treesitter 跳转 |
| `f/F/t/T` | 字符跳转（flash 接管） |

### 跳转（hop）

| 快捷键 | 说明 |
|--------|------|
| `leader leader w` | HopWord 全局词跳转 |
| `leader leader j` | HopLine 全局行跳转 |
| `leader leader f` | HopChar1 全局单字符跳转 |

### 多光标

| 快捷键 | 模式 | 说明 |
|--------|------|------|
| `I` | visual | 每行起始加光标 |
| `A` | visual | 每行末尾加光标 |
| `c` | visual (block) | 块模式下逐光标 change |

### 通用

| 快捷键 | 说明 |
|--------|------|
| `<` / `>` (visual) | 缩进保留选区 |

## 目录结构

```
vscode-nvim/
├── init.lua          # 主配置（单文件，inline lazy.nvim bootstrap）
├── lazy-lock.json    # 插件版本锁定
├── .gitignore
└── README.md
```

init.lua 做的事：设置 nvim 基础选项 → bootstrap lazy.nvim → 加载 4 个插件 → 绑定 VSCode action 快捷键。