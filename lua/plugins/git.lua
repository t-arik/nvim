return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(buffer)
        local nmap = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = buffer, desc = desc })
        end

        local gs = package.loaded.gitsigns
        nmap('<leader>hs', gs.stage_hunk)
        nmap('<leader>hr', gs.reset_hunk)
        nmap('<leader>hu', gs.undo_stage_hunk)
        nmap('<leader>hp', gs.preview_hunk)
        nmap('<leader>hb', function() gs.blame_line{full=true} end)
      end
    },
  }
}


