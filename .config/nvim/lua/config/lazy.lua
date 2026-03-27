local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        -- Importa qualquer arquivo que estiver dentro de lua/plugins/
        { import = "plugins" },
    },
    rocks = {
        enabled = false,
        hererocks = false,
    },
    checker = { enabled = true }, -- Verifica updates automaticamente
})
