-- Configuración básica de Neovim
-- init.lua

-- Establecer el líder para mapeos personalizados
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Configuraciones generales
vim.opt.number = true          -- Mostrar números de línea
vim.opt.relativenumber = true  -- Números de línea relativos
vim.opt.tabstop = 2            -- 2 espacios por tabulación
vim.opt.shiftwidth = 2         -- 2 espacios para indentación
vim.opt.expandtab = true       -- Convertir tabs en espacios
vim.opt.smartindent = true     -- Indentación inteligente
vim.opt.wrap = false           -- No envolver líneas
vim.opt.cursorline = true      -- Resaltar la línea actual
vim.opt.termguicolors = true   -- Soporte para colores verdaderos
vim.opt.mouse = "a"            -- Habilitar el ratón
vim.opt.clipboard = "unnamedplus" -- Usar portapapeles del sistema
vim.opt.ignorecase = true      -- Ignorar mayúsculas en búsquedas
vim.opt.smartcase = true       -- Sensible a mayúsculas si hay mayúsculas en la búsqueda
vim.opt.updatetime = 300       -- Tiempo de actualización más rápido (en ms)
vim.opt.timeoutlen = 500       -- Tiempo de espera para mapeos

-- Configuración del gestor de plugins: lazy.nvim
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

-- Lista de plugins
require("lazy").setup({
  -- Tema (colores)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- Usar la variante mocha
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
  -- Barra de estado
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
  -- Árbol de archivos
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
  -- Autocompletado
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
  -- Soporte para LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      -- Ejemplo de configuración para algunos servidores LSP
      lspconfig.pyright.setup {} -- Python
      lspconfig.tsserver.setup {} -- TypeScript/JavaScript
      lspconfig.clangd.setup {} -- C/C++
    end,
  },
  -- Resaltado de sintaxis mejorado
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

-- Mapeos de teclas
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- Configuración adicional para Telescope (búsqueda fuzzy)
local ok, telescope = pcall(require, "telescope")
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

-- Configuración para diagnósticos de LSP
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Mapeos para diagnósticos
vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Go to references" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })