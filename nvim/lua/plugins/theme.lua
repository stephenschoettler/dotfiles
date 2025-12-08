return {
  {
    "Mofiqul/dracula.nvim",
    lazy = false, -- Load immediately
    priority = 1000,
    config = function()
      local dracula = require("dracula")
      dracula.setup({
        -- This function targets specific parts of the UI to make them transparent
        overrides = function(colors)
          return {
            -- Main Backgrounds
            Normal = { bg = "NONE" },
            NormalFloat = { bg = "NONE" },
            NormalNC = { bg = "NONE" },

            -- Sidebars (NeoTree, etc.)
            NeoTreeNormal = { bg = "NONE" },
            NeoTreeNormalNC = { bg = "NONE" },
            NvimTreeNormal = { bg = "NONE" },

            -- UI Elements (Borders, Line Numbers)
            FloatBorder = { fg = colors.purple, bg = "NONE" }, -- Purple borders match Dracula
            LineNr = { fg = colors.comment, bg = "NONE" },
            WinSeparator = { fg = colors.selection, bold = true },

            -- Optional: Make Lualine background transparent to fit the "HUD" look
            StatusLine = { bg = "NONE" },
            StatusLineNC = { bg = "NONE" },
          }
        end,
      })
      vim.cmd.colorscheme("dracula")
    end,
  },

  -- Tell LazyVim to respect the choice
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },
}
