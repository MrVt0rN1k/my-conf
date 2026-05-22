-- Lazy.nvim (должен быть первым!)
require("theprimagen.lazy")

-- Основные настройки
require("theprimagen.set")
require("theprimagen.remap")

-- Cursor settings
require("cursor_color")
--require("cursor")
vim.cmd("source ~/.vimrc")

-- После-плагин файлы (если нужно)
require("plugin.colors")
