
-- init.lua

-- Establecer el líder para mapeos personalizados
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Show line numbers
vim.opt.relativenumber = true  -- Relative line numbers
vim.opt.tabstop = 2            -- 2 spaces per tab
vim.opt.shiftwidth = 2         -- 2 spaces for indentation
vim.opt.expandtab = true       -- Convert tabs to spaces
vim.opt.smartindent = true     -- Smart indentation
vim.opt.wrap = false           -- Do not wrap lines
vim.opt.cursorline = true      -- Highlight current line
vim.opt.termguicolors = true   -- True color support
vim.opt.mouse = "a"            -- Enable mouse
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.ignorecase = true      -- Ignore case in searches
vim.opt.smartcase = true       -- Case-sensitive if uppercase in search
vim.opt.updatetime = 300       -- Faster update time (in ms)
vim.opt.timeoutlen = 500       -- Timeout length for mappings

-- Plugin manager configuration: lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- plugins list
require("lazy").setup({
  -- Theme (colors)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- Use the mocha variant
        term_colors = true,
        transparent_background = false,
        integrations = {
          cmp = true,
          nvimtree = true,
          treesitter = true,
          telescope = true,
        },
      })
      vim.cmd([[colorscheme catppuccin]])
    end,
  },
  -- Status bar
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
        },
      })
    end,
  },
  -- file tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
      })
    end,
  },
  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
  -- LSP support
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.pyright.setup {} -- Python
      lspconfig.tsserver.setup {} -- TypeScript/JavaScript
      lspconfig.clangd.setup {} -- C/C++
    end,
  },
  -- Enhanced syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "typescript", "c", "cpp" },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
})

-- Key mapins 
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- Additional configuration for Telescope (fuzzy finding)
if ok then
  telescope.setup({
    defaults = {
      mappings = {
        i = {
          ["<C-j>"] = require("telescope.actions").move_selection_next,
          ["<C-k>"] = require("telescope.actions").move_selection_previous,
        },
      },
    },
  })
end

-- Diagnostic configuration LSP
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
})

-- diagnostic mapins
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Go to references" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
