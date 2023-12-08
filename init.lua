vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/nvim-cmp',
  "L3MON4D3/LuaSnip",
  "nvim-treesitter/nvim-treesitter",
  "tpope/vim-commentary",
  "tpope/vim-sleuth",
  "folke/neodev.nvim",
  "morhetz/gruvbox",
  "lewis6991/gitsigns.nvim",
  "nvim-lualine/lualine.nvim",
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
})

vim.cmd.colorscheme("gruvbox")
vim.o.colorcolumn = "100"
vim.o.hlsearch = false
vim.wo.number = true
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 50
vim.o.timeoutlen = 2000
vim.o.completeopt = "menuone,noselect"
vim.wo.signcolumn = "yes"
vim.o.termguicolors = true
vim.o.scrolloff = 8
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("x", "<leader>p", "\"_dP")

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank() end,
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
})

require("lualine").setup({
  options = {
    icons_enabled = false,
    section_separators = "",
    component_separators = "|",
  }
})

require("neodev").setup()
require("ibl").setup({ scope = { enabled = false } })
require("telescope.builtin")

local nmap = function(keys, func, desc, bufnr)
  vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
end

require("gitsigns").setup()
local gs = package.loaded.gitsigns
nmap("<leader>gr", gs.reset_hunk, "reset hunk")
nmap("<leader>gp", gs.preview_hunk, "preview hunk")
nmap("<leader>gb", function() gs.blame_line { full = true } end, "blame")
nmap("<leader>gt", gs.toggle_current_line_blame, "inline blame")

require("nvim-treesitter.configs").setup({
  sync_install = false,
  auto_install = false,
  highlight = { enable = true },
  indent = { enable = true },
  modules = {},
  ensure_installed = {},
  ignore_install = {}
})

require("mason").setup()
local on_attach = function(_, bufnr)
  local lspnmap = function(keys, func, desc)
    nmap(keys, func, "(LSP) " .. desc, bufnr)
  end
  lspnmap("<leader>rn", vim.lsp.buf.rename, "Rename")
  lspnmap("<leader>ca", vim.lsp.buf.code_action, "Code Action")
  lspnmap("gd", vim.lsp.buf.definition, "Goto Definition")
  lspnmap("gr", require("telescope.builtin").lsp_references, "Goto References")
  lspnmap("K", vim.lsp.buf.hover, "Hover Documentation")

  vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
    vim.lsp.buf.format()
  end, { desc = "Format current buffer with LSP" })
end

local servers = {
  clangd = {},
  pyright = {},
  rust_analyzer = {},
  tsserver = {},
  html = {},
  lua_ls = {},
  elixirls = {},
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),
})

require('lspconfig').racket_langserver.setup({
  capabilities = capabilities,
  on_attach = on_attach
})

require("mason-lspconfig").setup_handlers({
  function(server_name)
    require("lspconfig")[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
})

local cmp = require("cmp")
local luasnip = require("luasnip")
luasnip.config.setup({})

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm { select = true, },
  },
  sources = { { name = "nvim_lsp" }, { name = "luasnip" }, },
})
