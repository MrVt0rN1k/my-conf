-- =============================================
-- Lazy.nvim — Plugin Manager (DevOps Edition for Neovim 0.11+)
-- =============================================

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
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  -- Тема
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      vim.cmd("colorscheme rose-pine")
    end
  },

  "theprimeagen/harpoon",
  "mbbill/undotree",
  "tpope/vim-fugitive",

  -- =============================================
  -- LSP и автодополнение (Neovim 0.11+)
  -- =============================================

  -- Менеджер LSP серверов
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end
  },

  -- LSP конфиги (новый способ)
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Используем новый vim.lsp.config API
      vim.lsp.config("yamlls", {
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml", "yml" },
        root_markers = { ".git", ".yamlls.json" },
        settings = {
          yaml = {
            schemas = {
              kubernetes = "*.yaml",
              ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*.yml",
              ["http://json.schemastore.org/ansible-stable-2.9"] = "playbook.yml",
              ["http://json.schemastore.org/chart"] = "Chart.yaml",
              ["http://json.schemastore.org/helm-values"] = "values.yaml",
            },
            format = { enable = true },
            validate = true,
            hover = true,
            completion = true,
          },
        },
      })

      vim.lsp.config("gopls", {
        cmd = { "gopls" },
        filetypes = { "go" },
        root_markers = { "go.mod", "go.work", ".git" },
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      vim.lsp.config("ts_ls", {  -- вместо deprecated tsserver
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "typescript", "javascript", "tsx", "jsx" },
        root_markers = { "tsconfig.json", "package.json", ".git" },
      })

      vim.lsp.config("bashls", {
        cmd = { "bash-language-server", "start" },
        filetypes = { "bash", "sh" },
        root_markers = { ".git" },
      })

      vim.lsp.config("dockerls", {
        cmd = { "docker-langserver", "--stdio" },
        filetypes = { "dockerfile" },
        root_markers = { "Dockerfile", ".git" },
      })

      vim.lsp.config("terraformls", {
        cmd = { "terraform-ls", "serve" },
        filetypes = { "terraform", "tf" },
        root_markers = { ".terraform", ".git" },
      })

      vim.lsp.config("sqlls", {
        cmd = { "sql-language-server", "up", "--method", "stdio" },
        filetypes = { "sql" },
        root_markers = { ".git" },
      })

      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", "lua", ".git" },
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            telemetry = { enable = false },
          },
        },
      })

      -- Базовые хоткеи для LSP
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
      end

      -- Активируем LSP серверы
      vim.lsp.enable("yamlls")
      vim.lsp.enable("gopls")
      vim.lsp.enable("pyright")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("bashls")
      vim.lsp.enable("dockerls")
      vim.lsp.enable("terraformls")
      vim.lsp.enable("sqlls")
      vim.lsp.enable("lua_ls")

      -- Настройка автокоманд для on_attach (новый способ)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          on_attach(nil, args.buf)
        end,
      })
    end,
  },

  -- =============================================
  -- ДОБАВЛЕНО: Автозакрытие скобок
  -- =============================================
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        ts_config = {
          lua = { "string", "source" },
          javascript = { "string", "template_string" },
          typescript = { "string", "template_string" },
          python = { "string" },
          go = { "string" },
          yaml = { "string" },
        },
        disable_filetype = { "TelescopePrompt", "vim" },
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
          pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "PmenuSel",
          highlight_grey = "Comment",
        },
      })
    end,
  },

  -- Автодополнение (ОБНОВЛЕНО с интеграцией autopairs)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",
      "windwp/nvim-autopairs",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      -- Интеграция с nvim-autopairs
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "buffer", keyword_length = 3 },
        }),
        experimental = {
          ghost_text = true,
        },
      })

      -- Автодополнение для командной строки
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "cmdline" },
          { name = "path" },
        },
      })
    end,
  },

  -- Линтер
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")

      -- DevOps линтеры
      lint.linters_by_ft = {
        yaml = { "yamllint" },
        typescript = { "eslint" },
        javascript = { "eslint" },
        python = { "pylint" },
        go = { "golangcilint" },
        bash = { "shellcheck" },
        sh = { "shellcheck" },
        sql = { "sqlfluff" },
        dockerfile = { "hadolint" },
        terraform = { "tflint" },
        json = { "jsonlint" },
        markdown = { "markdownlint" },
      }

      -- Автоматический запуск линтера
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          pcall(lint.try_lint)
        end,
      })
    end,
  },

  -- =============================================
  -- GIT ИНТЕГРАЦИЯ (ОБНОВЛЕНО с хоткеями)
  -- =============================================
  
  -- Gitsigns - показывает изменения в файлах
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = '│' },
          change       = { text = '│' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          
          -- Хоткеи для работы с гитом в режиме редактирования
          vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = 'Stage hunk' })
          vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = 'Reset hunk' })
          vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr, desc = 'Stage buffer' })
          vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr, desc = 'Undo stage hunk' })
          vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Preview hunk' })
          vim.keymap.set('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { buffer = bufnr, desc = 'Blame line' })
          vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr, desc = 'Diff this' })
          
          -- Навигация по изменённым строкам
          vim.keymap.set('n', ']c', function() gs.next_hunk() end, { buffer = bufnr, desc = 'Next hunk' })
          vim.keymap.set('n', '[c', function() gs.prev_hunk() end, { buffer = bufnr, desc = 'Prev hunk' })
        end,
      })
    end,
  },

  -- LazyGit - TUI интерфейс для Git
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
      { "<leader>gG", "<cmd>LazyGit currentfile<cr>", desc = "Open LazyGit (current file)" },
    },
  },

  -- =============================================
  -- ДОБАВЛЕНО: Полезные сниппеты для DevOps
  -- =============================================
  {
    "rafamadriz/friendly-snippets",
    dependencies = { "L3MON4D3/LuaSnip" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
})
