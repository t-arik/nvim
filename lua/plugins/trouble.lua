return {
  {
    "folke/trouble.nvim",
    opts = function()
      local trouble = require("trouble")
      vim.keymap.set("n", "<leader>tt", function() trouble.toggle() end)
      return {
        icons = false,
        fold_open = "", -- icon used for open folds
        fold_closed = "", -- icon used for closed folds
        signs = {
          error = "E",
          warning = "W",
          hint = "H",
          information = "I",
          other = "O",
        },
      }
    end,
  }
}
