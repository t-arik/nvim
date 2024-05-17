return {
  {
    "github/copilot.vim",
    config = function ()
      vim.keymap.set('n', '<Leader>cd', '<Cmd>Copilot disable<CR>')
      vim.keymap.set('n', '<Leader>ce', '<Cmd>Copilot enable<CR>')
    end
  }
}
