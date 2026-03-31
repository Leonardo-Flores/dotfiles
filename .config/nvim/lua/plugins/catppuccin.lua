return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "mocha",
        transparent_background = true,
        integrations = {
            cmp = true,
            treesitter = true,
            telescope = { enabled = true },
            harpoon = true,
            mason = true,
            fidget = true,
        },
    },
    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme("catppuccin")
    end,
}
