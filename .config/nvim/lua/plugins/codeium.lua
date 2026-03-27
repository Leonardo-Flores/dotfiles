return {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
    },
    config = function()
        require("minuet").setup({
            provider = "claude",
            notify = "warn",
            request_timeout = 4,
            throttle = 1500,
            debounce = 600,
            provider_options = {
                claude = {
                    model = "claude-sonnet-4-20250514",
                    max_tokens = 512,
                    system = {
                        type = "text",
                        text = "You are a code completion assistant. Complete the code naturally and concisely. Only output the completion, no explanations.",
                    },
                },
            },
        })
    end,
}
