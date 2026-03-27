return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local configs = require("nvim-treesitter.config")

        configs.setup({
            ensure_installed = { "c", "lua", "vim", "vimdoc", "python", "javascript", "html", "css", "bash", "markdown" },
            sync_install = false,
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        })
    end
}
