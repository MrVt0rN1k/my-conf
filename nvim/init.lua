-- Подключение packer
vim.cmd [[packadd packer.nvim]]

-- Инициализация packer
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- сюда добавляй свои плагины
end)

require("theprimagen")
require("cursor").setup()

