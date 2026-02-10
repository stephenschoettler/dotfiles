return {
  -- Styling for the Status Line (Lualine)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      -- DRACULA PALETTE
      local colors = {
        bg = "NONE", -- Transparent
        fg = "#f8f8f2", -- Whiteish
        yellow = "#f1fa8c",
        cyan = "#8be9fd",
        darkblue = "#6272a4",
        green = "#50fa7b",
        orange = "#ffb86c",
        violet = "#bd93f9",
        magenta = "#ff79c6",
        blue = "#8be9fd",
        red = "#ff5555",
      }

      -- CUSTOM "GHOST" THEME
      local ghost_theme = {
        normal = {
          a = { fg = colors.violet, bg = colors.bg, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        insert = {
          a = { fg = colors.green, bg = colors.bg, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        visual = {
          a = { fg = colors.magenta, bg = colors.bg, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        command = {
          a = { fg = colors.orange, bg = colors.bg, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        replace = {
          a = { fg = colors.red, bg = colors.bg, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg },
          c = { fg = colors.fg, bg = colors.bg },
        },
        inactive = {
          a = { fg = colors.darkblue, bg = colors.bg, gui = "bold" },
          b = { fg = colors.darkblue, bg = colors.bg },
          c = { fg = colors.darkblue, bg = colors.bg },
        },
      }

      -- APPLY SETTINGS
      opts.options.theme = ghost_theme

      -- Wireframe separators (Clean vertical lines)
      opts.options.component_separators = { left = "|", right = "|" }
      opts.options.section_separators = { left = "", right = "" } -- No bulky arrows

      -- OVERRIDE SECTIONS
      -- 12-Hour Clock in the far right (lualine_z)
      opts.sections.lualine_z = {
        {
          function()
            return " " .. os.date("%I:%M %p")
          end,
          color = { fg = colors.cyan, bg = "NONE", gui = "bold" },
        },
      }

      -- Clean up the far left (Mode name)
      opts.sections.lualine_a = {
        {
          "mode",
          fmt = function(str)
            return str:sub(1, 1)
          end, -- Shows "N", "I", "V" instead of full name
          padding = { left = 1, right = 1 },
        },
      }
    end,
  },

  -- Styling for Command Line (Noice)
  {
    "folke/noice.nvim",
    opts = {
      views = {
        cmdline_popup = {
          border = { style = "rounded" },
          win_options = {
            winhighlight = { Normal = "NormalFloat", FloatBorder = "FloatBorder" },
          },
        },
      },
    },
  },
}
