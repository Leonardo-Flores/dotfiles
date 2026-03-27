return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    opts = {
        provider = "claude",
        providers = {
            claude = {
                endpoint = "https://api.anthropic.com",
                model = "claude-sonnet-4-20250514",
                timeout = 30000,
                extra_request_body = {
                    max_tokens = 8192,
                    temperature = 0,
                },
            },
        },
    },
    build = "make",
    dependencies = {
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "hrsh7th/nvim-cmp",
        "nvim-tree/nvim-web-devicons",
    },
}
