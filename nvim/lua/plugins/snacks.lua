return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = { -- Это для боковой панели
            hidden = true, -- Показывать dot-файлы
            ignored = true, -- Показывать файлы из .gitignore (опционально)
          },
        },
      },
    },
  },
}
