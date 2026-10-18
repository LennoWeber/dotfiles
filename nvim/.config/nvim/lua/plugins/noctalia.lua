-- Noctalia Theme deaktiviert zugunsten von Gruvbox
-- stylua: ignore
if true then return {} end

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        local theme = require("config.noctalia-theme")
        theme.apply()
        theme.attach_signal()
        theme.attach_watchers()
      end,
    },
    init = function()
      vim.api.nvim_create_user_command("NoctaliaTheme", function()
        require("config.noctalia-theme").apply()
      end, { desc = "Reload active Noctalia palette" })
    end,
  },
}
