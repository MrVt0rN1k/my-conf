vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

-- =============================================
-- DevOps дополнительные настройки
-- =============================================

-- Включаем подсветку синтаксиса
vim.cmd("syntax enable")
vim.opt.syntax = "on"

-- Настройки для диагностики (ошибки/варнинги)
vim.diagnostic.config({
  virtual_text = true,        -- текст ошибки рядом с линией
  signs = true,               -- значки в gutter
  underline = true,           -- подчеркивание ошибок
  update_in_insert = false,   -- обновлять только в нормальном режиме
  severity_sort = true,       -- сортировка по серьезности
  float = {
    source = true,            -- показывать источник ошибки
    border = "rounded",       -- скругленная граница
  },
})

-- Значки для диагностики
vim.fn.sign_define("DiagnosticSignError", { text = "✘", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "⚠", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "ℹ", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "➤", texthl = "DiagnosticSignHint" })

-- Автоматические настройки для разных типов файлов (DevOps специфика)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "120"  -- YAML часто длиннее
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false     -- Go использует табы
    vim.opt_local.colorcolumn = "120"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "88"    -- PEP8 рекомендует 79, но 88 норм
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "bash", "sh" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "120"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "120"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "javascript", "tsx", "jsx" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "100"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "dockerfile" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "terraform" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = "120"
  end,
})

-- Дополнительные полезные настройки для DevOps
vim.opt.showmode = false      -- показываем режим в статуслайне (если есть)
vim.opt.laststatus = 3        -- глобальный статуслайн
vim.opt.showmatch = true       -- подсвечивать парные скобки
vim.opt.matchtime = 2          -- время подсветки в десятых секунды

-- Улучшенный поиск
vim.opt.ignorecase = true      -- игнорировать регистр
vim.opt.smartcase = true       -- но не игнорировать если есть заглавные

-- Работа с буферами
vim.opt.hidden = true          -- можно переключать буферы без сохранения
vim.opt.confirm = true         -- спрашивать подтверждение

-- Производительность для больших файлов (логи, дампы)
vim.opt.timeoutlen = 500       -- время ожидания для маппингов
vim.opt.ttimeoutlen = 50       -- время для key codes

-- Включить мышь (удобно для выбора в telescope)
vim.opt.mouse = "a"

-- Форматирование
vim.opt.formatoptions = "jcroqlnt"  -- умное форматирование
-- =============================================
-- ДОБАВЛЕНО: Настройки для автодополнения и скобок
-- =============================================

-- Настройки меню автодополнения
vim.opt.completeopt = "menu,menuone,noselect,preview"
vim.opt.pumheight = 10

-- Задержка для автодополнения
vim.opt.updatetime = 200

-- Визуальные настройки для автодополнения
vim.api.nvim_set_hl(0, "CmpItemKind", { link = "Comment" })
vim.api.nvim_set_hl(0, "CmpItemAbbr", { link = "Normal" })
vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { link = "Identifier" })

-- Показывать пары скобок
vim.opt.showmatch = true
vim.opt.matchtime = 2
