vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

require("lazy").setup({
  "tpope/vim-sleuth",
  "tpope/vim-fugitive",
  "tpope/vim-commentary",
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/neodev.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      "saadparwaiz1/cmp_luasnip",
    }
  },
  "morhetz/gruvbox",
  "nvim-treesitter/nvim-treesitter",
  "lewis6991/gitsigns.nvim",
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        icons_enabled = false,
        component_separators = "|",
        section_separators = "",
      }
    }
  },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  { "j-hui/fidget.nvim", tag = "legacy", event = "LspAttach" }
})

vim.cmd.colorscheme("gruvbox")
-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.o.cursorline = true
-- vim.o.colorcolumn = "100"
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

local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "lua", "vim", "vimdoc", "go", "rust", "html", "javascript" },
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
  modules = {},
  ignore_install = {}
})

require("ibl").setup({ scope = { enabled = false }, })

local nmap = function(keys, func, desc, bufnr)
  vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
end

local ts = require("telescope.builtin")
nmap("<leader><leader>", ts.builtin, "Telescope")
nmap("<leader>ff", ts.find_files, "Find files")
nmap("<leader>fg", ts.live_grep, "Live-Grep")
nmap("<leader>fb", ts.buffers, "Find in Buffers")

require("gitsigns").setup()
local gs = package.loaded.gitsigns
nmap("<leader>hr", gs.reset_hunk, "Reset Hunk")
nmap("<leader>hp", gs.preview_hunk, "Preview Hunk")
nmap("<leader>hb", function() gs.blame_line { full = true } end, "Blame")
nmap("<leader>tb", gs.toggle_current_line_blame, "Blame Inline Toggle")


-- LSP ---
require("fidget").setup()
require("mason").setup()
local on_attach = function(_, bufnr)
  local lspnmap = function(keys, func, desc)
    if desc then desc = "(LSP) " .. desc end
    nmap(keys, func, desc, bufnr)
  end

  lspnmap("<leader>rn", vim.lsp.buf.rename, "Rename")
  lspnmap("<leader>ca", vim.lsp.buf.code_action, "Code Action")
  lspnmap("gd", vim.lsp.buf.definition, "Goto Definition")
  lspnmap("gr", require("telescope.builtin").lsp_references, "Goto References")
  lspnmap("gI", require("telescope.builtin").lsp_implementations, "Goto Implementation")
  lspnmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
  lspnmap("K", vim.lsp.buf.hover, "Hover Documentation")
  lspnmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
  lspnmap("gD", vim.lsp.buf.declaration, "Goto Declaration")

  -- Create a command `:Format` local to the LSP buffer
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
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

require("neodev").setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

require("mason-lspconfig").setup({ ensure_installed = vim.tbl_keys(servers), })
require("mason-lspconfig").setup_handlers {
  function(server_name)
    require("lspconfig")[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
}

local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-Space>"] = cmp.mapping.complete {},
    ["<CR>"] = cmp.mapping.confirm { select = true, },
  },
  sources = { { name = "nvim_lsp" }, { name = "luasnip" }, },
}

