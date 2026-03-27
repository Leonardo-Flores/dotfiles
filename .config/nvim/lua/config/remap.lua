vim.g.mapleader = " "
-- O famoso Project View (abre o explorador de arquivos)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Mover blocos selecionados no modo Visual (coisa de bruxo)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Manter o cursor no meio ao dar scroll ou buscar
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- O maior truque: colar sem perder o que estava no buffer principal
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Copiar para o clipboard do sistema (o yank do líder)
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
