return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      {
        "<leader>oa",
        function()
          require("opencode").ask("@this: ", { submit = true })
        end,
        desc = "Opencode: Ask",
      },
      {
        "<leader>os",
        function()
          require("opencode").select()
        end,
        desc = "Opencode: Select Action",
      },
      {
        "<leader>op",
        function()
          require("opencode").prompt("@this")
        end,
        desc = "Opencode: Add to Prompt",
      },
      {
        "<leader>ot",
        function()
          require("opencode").toggle()
        end,
        desc = "Opencode: Toggle TUI",
      },
    },
    config = function()
      vim.g.opencode_opts = {}
    end,
  },
}
