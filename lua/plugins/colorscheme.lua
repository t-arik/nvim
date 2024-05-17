return {
  {
    "morhetz/gruvbox",
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      styles = {
        italic = false,
      }
    },
    config = function() vim.cmd.colorscheme("rose-pine") end,
  }
}
