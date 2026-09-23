-- vscode-neovim 专用独立配置
-- 通过 settings.json 的 vscode-neovim.NVIM_APPNAME=vscode-nvim 加载
-- 完全独立于主 nvim 配置 (~/.config/nvim)，只加载 VSCode 兼容插件

vim.opt.clipboard = "unnamedplus"
vim.opt.whichwrap = "b,s"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.virtualedit = "block"
vim.opt.sidescrolloff = 8
vim.opt.scrolloff = 5
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 优先用 vscode-neovim 提供的剪贴板 provider
if vim.g.vscode_clipboard then
  vim.g.clipboard = vim.g.vscode_clipboard
end

-- 通知转 VSCode; 语法高亮由 VSCode 渲染, nvim 侧关闭省开销
if vim.g.vscode then
  vim.notify = require("vscode").notify
end
vim.cmd.syntax("off")

-- lazy.nvim bootstrap (独立 data 目录: %LOCALAPPDATA%\vscode-nvim-data)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- vim.surround 替代: ys / cs / ds; visual 加包围 gs / gS (S 让给 flash)
  -- v4 起 keymaps 移出 setup: 禁用默认 visual 键(默认 S 会撞 flash), 手动绑 <Plug>
  {
    "kylechui/nvim-surround",
    version = "^4.0.0",
    event = "VeryLazy",
    init = function()
      vim.g.nvim_surround_no_visual_mappings = true
    end,
    config = function()
      require("nvim-surround").setup({})
      vim.keymap.set("x", "gs", "<Plug>(nvim-surround-visual)", { desc = "Add surround" })
      vim.keymap.set("x", "gS", "<Plug>(nvim-surround-visual-line)", { desc = "Add surround on new lines" })
    end,
  },

  -- vim.sneak 替代: s/S 双字符跳转
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        normal = { jump_labels = true, matchers = { "f", "F", "t", "T" } },
        visual = { jump_labels = true },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },

  -- vim.easymotion 替代: <leader><leader> 触发
  {
    "smoka7/hop.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("hop").setup()
      vim.keymap.set("n", "<leader><leader>w", "<cmd>HopWord<CR>", { desc = "easymotion word" })
      vim.keymap.set("n", "<leader><leader>j", "<cmd>HopLine<CR>", { desc = "easymotion line" })
      vim.keymap.set("n", "<leader><leader>f", "<cmd>HopChar1<CR>", { desc = "easymotion char" })
    end,
  },

  -- 多光标: visual 选区转 VSCode 多光标 (官方辅助插件, 不含编辑功能)
  -- 建光标用 VSCode 原生: ctrl+d / alt+d / ctrl+shift+l
  {
    "vscode-neovim/vscode-multi-cursor.nvim",
    lazy = true,
    cond = not not vim.g.vscode,
    opts = { default_mappings = false },
    keys = {
      { "I", function()
          require("vscode-multi-cursor").start_left_edge({ no_selection = vim.fn.mode() == "\x16" })
        end, mode = "x", desc = "Cursors at line start" },
      { "A", function()
          require("vscode-multi-cursor").start_right({ no_selection = vim.fn.mode() == "\x16" })
        end, mode = "x", desc = "Cursors at line end" },
      { "c", function()
          if vim.fn.mode() == "\x16" then
            require("vscode-multi-cursor").start_right()
            require("vscode").action("deleteLeft")
            return "<Ignore>"
          end
          return "c"
        end, mode = "x", expr = true, desc = "Cursors then change" },
    },
  },
})

-- leader 键映射到 VSCode 原生命令
-- 1.19 起 VimScript 接口 VSCodeNotify 已废弃, 统一走 Lua API
local function vscode(action)
  return string.format("<cmd>lua require('vscode').action('%s')<CR>", action)
end

vim.keymap.set("n", "<leader>ff", vscode("workbench.action.quickOpen"), { desc = "Quick open file" })
vim.keymap.set("n", "<leader>fw", vscode("workbench.action.findInFiles"), { desc = "Find in files" })
vim.keymap.set("n", "<leader>e", vscode("workbench.action.toggleSidebarVisibility"), { desc = "Toggle sidebar" })
vim.keymap.set("n", "<leader>p", vscode("workbench.action.showCommands"), { desc = "Command palette" })
vim.keymap.set("n", "<leader>w", vscode("workbench.action.files.save"), { desc = "Save file" })
vim.keymap.set("n", "<leader>q", vscode("workbench.action.closeActiveEditor"), { desc = "Close editor" })
vim.keymap.set("n", "<leader>bo", vscode("workbench.action.closeOtherEditors"), { desc = "Close other editors" })
vim.keymap.set("n", "<leader>bl", vscode("workbench.action.closeEditorsToTheLeft"), { desc = "Close left editors" })
vim.keymap.set("n", "<leader>br", vscode("workbench.action.closeEditorsToTheRight"), { desc = "Close right editors" })

-- H/L 改行首尾 (屏幕跳转因 scrolloff 少用, ^/$ 难按)
vim.keymap.set({ "n", "x" }, "H", "^", { desc = "Line start" })
vim.keymap.set({ "n", "x" }, "L", "g_", { desc = "Line end" })

-- LSP 类跳转归 IDE (nvim 侧无 LSP)
vim.keymap.set("n", "gy", vscode("editor.action.goToTypeDefinition"), { desc = "Type definition" })
vim.keymap.set("n", "gr", vscode("editor.action.goToReferences"), { desc = "References" })
vim.keymap.set("n", "gI", vscode("editor.action.goToImplementation"), { desc = "Implementation" })

-- 跳转历史归 VSCode (nvim 跳转表不追踪 IDE 导航)
vim.keymap.set({ "n", "x" }, "<C-o>", vscode("workbench.action.navigateBack"), { desc = "Jump back" })
vim.keymap.set({ "n", "x" }, "<C-i>", vscode("workbench.action.navigateForward"), { desc = "Jump forward" })

-- git 变更块跳转 (普通编辑器 + diff 编辑器双保险)
vim.keymap.set("n", "]h", function()
  local v = require("vscode")
  v.action("workbench.action.editor.nextChange")
  v.action("workbench.action.compareEditor.nextChange")
end, { desc = "Next git change" })
vim.keymap.set("n", "[h", function()
  local v = require("vscode")
  v.action("workbench.action.editor.previousChange")
  v.action("workbench.action.compareEditor.previousChange")
end, { desc = "Prev git change" })

-- 诊断跳转
vim.keymap.set("n", "]d", vscode("editor.action.marker.next"), { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", vscode("editor.action.marker.prev"), { desc = "Prev diagnostic" })

-- visual 缩进保留选区
vim.keymap.set("x", "<", "<gv", { desc = "Deindent keep selection" })
vim.keymap.set("x", ">", ">gv", { desc = "Indent keep selection" })
