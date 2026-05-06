vim.g.mapleader = " "
vim.keymap.set("n", "<leader>ga", ":Git add .<CR>", { desc = "Git add all" })
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git status" })
vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gl", ":Git pull<CR>", { desc = "Git pull" })
vim.keymap.set("n", "<leader>gb", ":Git branch<CR>", { desc = "Git branch" })
vim.keymap.set("n", "<leader>gch", ":Git checkout<Space>", { desc = "Git checkout" })
vim.keymap.set("n", "<leader>gst", ":Git stash<CR>", { desc = "Git stash" })
vim.keymap.set("n", "<leader>gsp", ":Git stash pop<CR>", { desc = "Git stash pop" })

