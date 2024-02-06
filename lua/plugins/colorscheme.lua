return {
  {
    "morhetz/gruvbox",
    config = function() vim.cmd.colorscheme("gruvbox") end,
  },
  "AlexvZyl/nordic.nvim",
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = {}, }
}
