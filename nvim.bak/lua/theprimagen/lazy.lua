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
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "mrloop/telescope-git-branch.nvim",
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        extensions = {
          git_branch = {
            mappings = {
              i = {
                ["<CR>"] = function(prompt_bufnr)
                  local entry = require("telescope.actions.state").get_selected_entry()
                  local branch_name = entry[1]
                  vim.cmd("git checkout " .. branch_name)
                  require("telescope.actions").close(prompt_bufnr)
                end,
              },
            },
          },
        },
        pickers = {
          git_commits = {
            theme = "dropdown",
            layout_config = { height = 0.6 },
          },
          git_status = {
            theme = "dropdown",
            layout_config = { height = 0.8 },
          },
        },
      })
      telescope.load_extension("git_branch")
    end
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

  -- Diffview.nvim
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    },
    config = function()
      require("diffview").setup({
        view = {
          merge_tool = {
            layout = "diff3_horizontal",
          },
        },
      })
    end,
  },

  -- =============================================
  -- LSP и автодополнение (Neovim 0.11+)
  -- =============================================

  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
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

      vim.lsp.config("ts_ls", {
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

      vim.lsp.enable("yamlls")
      vim.lsp.enable("gopls")
      vim.lsp.enable("pyright")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("bashls")
      vim.lsp.enable("dockerls")
      vim.lsp.enable("terraformls")
      vim.lsp.enable("sqlls")
      vim.lsp.enable("lua_ls")

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          on_attach(nil, args.buf)
        end,
      })
    end,
  },

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

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "cmdline" },
          { name = "path" },
        },
      })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")

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

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          pcall(lint.try_lint)
        end,
      })
    end,
  },

  -- GIT INTEGRATION
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

          vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = 'Stage hunk' })
          vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = 'Reset hunk' })
          vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr, desc = 'Stage buffer' })
          vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr, desc = 'Undo stage hunk' })
          vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Preview hunk' })
          vim.keymap.set('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { buffer = bufnr, desc = 'Blame line' })
          vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr, desc = 'Diff this' })
          vim.keymap.set('n', ']c', function() gs.next_hunk() end, { buffer = bufnr, desc = 'Next hunk' })
          vim.keymap.set('n', '[c', function() gs.prev_hunk() end, { buffer = bufnr, desc = 'Prev hunk' })
        end,
      })
    end,
  },

  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
      { "<leader>gG", "<cmd>LazyGit currentfile<cr>", desc = "Open LazyGit (current file)" },
    },
  },

  {
    "rafamadriz/friendly-snippets",
    dependencies = { "L3MON4D3/LuaSnip" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
})

-- =============================================
-- FULL GIT WORKFLOW KEYMAPS
-- =============================================

local function notify(msg, level)
  level = level or "info"
  vim.notify(msg, level, { title = "Git", timeout = 2000 })
end

-- Branches
local function git_checkout_branch()
  require('telescope').extensions.git_branch.branches({
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<CR>', function()
        local selection = require('telescope.actions.state').get_selected_entry()
        if selection then
          local branch = selection[1]
          vim.cmd('Git checkout ' .. branch)
          notify('Switched to branch: ' .. branch)
        end
        require('telescope.actions').close(prompt_bufnr)
      end)
      return true
    end,
  })
end

vim.keymap.set('n', '<leader>gco', git_checkout_branch, { desc = 'Git: Checkout branch' })
vim.keymap.set('n', '<leader>gb', git_checkout_branch, { desc = 'Git: Switch branch' })
vim.keymap.set('n', '<leader>gcb', function()
  local branch = vim.fn.input('New branch name: ')
  if branch ~= '' then
    vim.cmd('Git checkout -b ' .. branch)
    notify('Created branch: ' .. branch)
  end
end, { desc = 'Git: Create branch' })
vim.keymap.set('n', '<leader>gdb', function()
  local branch = vim.fn.input('Branch to delete: ')
  if branch ~= '' then
    vim.cmd('Git branch -d ' .. branch)
    notify('Deleted branch: ' .. branch, "warn")
  end
end, { desc = 'Git: Delete branch' })

-- Commits
vim.keymap.set('n', '<leader>gc', function()
  require('telescope.builtin').git_status({
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<C-c>', function()
        require('telescope.actions').close(prompt_bufnr)
        local commit_msg = vim.fn.input('Commit message: ')
        if commit_msg ~= '' then
          vim.cmd('Git commit -m "' .. commit_msg .. '"')
          notify('Committed: ' .. commit_msg)
        end
      end)
      return true
    end,
  })
end, { desc = 'Git: Commit' })

vim.keymap.set('n', '<leader>gca', function()
  local commit_msg = vim.fn.input('Commit message (all files): ')
  if commit_msg ~= '' then
    vim.cmd('Git add .')
    vim.cmd('Git commit -m "' .. commit_msg .. '"')
    notify('Committed all: ' .. commit_msg)
  end
end, { desc = 'Git: Commit all' })

vim.keymap.set('n', '<leader>gcf', function()
  local commit_msg = vim.fn.input('Commit message (current file): ')
  if commit_msg ~= '' then
    local file = vim.fn.expand('%:p')
    vim.cmd('Git add ' .. file)
    vim.cmd('Git commit -m "' .. commit_msg .. '"')
    notify('Committed file: ' .. commit_msg)
  end
end, { desc = 'Git: Commit current file' })

vim.keymap.set('n', '<leader>gcaa', function()
  local amend_msg = vim.fn.input('Amend message (empty to keep): ')
  if amend_msg == '' then
    vim.cmd('Git commit --amend --no-edit')
    notify('Amended commit')
  else
    vim.cmd('Git commit --amend -m "' .. amend_msg .. '"')
    notify('Amended: ' .. amend_msg)
  end
end, { desc = 'Git: Amend commit' })

vim.keymap.set('n', '<leader>gl', function()
  require('telescope.builtin').git_commits()
end, { desc = 'Git: Show commits' })
vim.keymap.set('n', '<leader>gL', function()
  require('telescope.builtin').git_bcommits()
end, { desc = 'Git: File commits' })

-- Merge & Rebase
vim.keymap.set('n', '<leader>gm', function()
  local branches = {}
  local handle = io.popen('git branch --format="%(refname:short)"')
  if handle then
    for branch in handle:lines() do
      table.insert(branches, branch)
    end
    handle:close()
  end
  vim.ui.select(branches, { prompt = 'Merge branch:' }, function(choice)
    if choice then
      vim.cmd('Git merge ' .. choice)
      notify('Merged: ' .. choice)
    end
  end)
end, { desc = 'Git: Merge' })

vim.keymap.set('n', '<leader>grb', function()
  local branches = {}
  local handle = io.popen('git branch --format="%(refname:short)"')
  if handle then
    for branch in handle:lines() do
      table.insert(branches, branch)
    end
    handle:close()
  end
  vim.ui.select(branches, { prompt = 'Rebase onto:' }, function(choice)
    if choice then
      vim.cmd('Git rebase ' .. choice)
      notify('Rebasing onto: ' .. choice)
    end
  end)
end, { desc = 'Git: Rebase' })

vim.keymap.set('n', '<leader>grbc', '<cmd>Git rebase --continue<cr>', { desc = 'Git: Rebase continue' })
vim.keymap.set('n', '<leader>grbs', '<cmd>Git rebase --skip<cr>', { desc = 'Git: Rebase skip' })
vim.keymap.set('n', '<leader>grba', '<cmd>Git rebase --abort<cr>', { desc = 'Git: Rebase abort' })

-- Stash
vim.keymap.set('n', '<leader>gsa', '<cmd>Git stash push<cr>', { desc = 'Git: Stash' })
vim.keymap.set('n', '<leader>gsn', function()
  local name = vim.fn.input('Stash name: ')
  if name ~= '' then
    vim.cmd('Git stash push -m "' .. name .. '"')
    notify('Stashed: ' .. name)
  end
end, { desc = 'Git: Stash with name' })
vim.keymap.set('n', '<leader>gsp', '<cmd>Git stash pop<cr>', { desc = 'Git: Stash pop' })
vim.keymap.set('n', '<leader>gsl', '<cmd>Git stash list<cr>', { desc = 'Git: Stash list' })
vim.keymap.set('n', '<leader>gsd', '<cmd>Git stash drop<cr>', { desc = 'Git: Stash drop' })
vim.keymap.set('n', '<leader>gss', '<cmd>Git stash show<cr>', { desc = 'Git: Stash show' })

-- Push/Pull/Fetch
vim.keymap.set('n', '<leader>gp', function()
  vim.ui.select({ 'push', 'push --force-with-lease', 'push --force' }, {
    prompt = 'Push options:',
  }, function(choice)
    if choice then
      vim.cmd('Git ' .. choice)
      notify(choice)
    end
  end)
end, { desc = 'Git: Push' })
vim.keymap.set('n', '<leader>gP', '<cmd>Git pull<cr>', { desc = 'Git: Pull' })
vim.keymap.set('n', '<leader>gf', '<cmd>Git fetch<cr>', { desc = 'Git: Fetch' })
vim.keymap.set('n', '<leader>gfa', '<cmd>Git fetch --all<cr>', { desc = 'Git: Fetch all' })

-- Info
vim.keymap.set('n', '<leader>gst', function()
  require('telescope.builtin').git_status()
end, { desc = 'Git: Status' })
vim.keymap.set('n', '<leader>gbl', '<cmd>Git blame<cr>', { desc = 'Git: Blame' })
vim.keymap.set('n', '<leader>gdf', '<cmd>Git diff<cr>', { desc = 'Git: Diff' })
vim.keymap.set('n', '<leader>glg', '<cmd>Git log --graph --oneline --decorate<cr>', { desc = 'Git: Log graph' })

-- Reset & Undo
vim.keymap.set('n', '<leader>gu', function()
  local file = vim.fn.expand('%:p')
  vim.cmd('Git reset HEAD ' .. file)
  notify('Unstaged: ' .. vim.fn.expand('%:t'))
end, { desc = 'Git: Unstage' })
vim.keymap.set('n', '<leader>gR', function()
  local confirm = vim.fn.confirm('Reset current file?', "&Yes\n&No", 2)
  if confirm == 1 then
    local file = vim.fn.expand('%:p')
    vim.cmd('Git checkout HEAD -- ' .. file)
    notify('Reset file', "warn")
  end
end, { desc = 'Git: Reset file' })
vim.keymap.set('n', '<leader>grs', '<cmd>Git reset --soft HEAD~1<cr>', { desc = 'Git: Soft reset' })
vim.keymap.set('n', '<leader>grh', '<cmd>Git reset --hard HEAD~1<cr>', { desc = 'Git: Hard reset' })

-- Help command
vim.api.nvim_create_user_command('GitHelp', function()
  local help_lines = {
    "Git Hotkeys:",
    "",
    "Branches:",
    "  <leader>gco/gb - Switch branch",
    "  <leader>gcb    - Create branch",
    "  <leader>gdb    - Delete branch",
    "",
    "Commits:",
    "  <leader>gc     - Commit (select files)",
    "  <leader>gca    - Commit all",
    "  <leader>gcf    - Commit current file",
    "  <leader>gcaa   - Amend commit",
    "  <leader>gl     - Show commits",
    "",
    "Merge/Rebase:",
    "  <leader>gm     - Merge branch",
    "  <leader>grb    - Rebase",
    "  <leader>grbc   - Rebase continue",
    "  <leader>grba   - Rebase abort",
    "",
    "Stash:",
    "  <leader>gsa    - Stash",
    "  <leader>gsn    - Stash named",
    "  <leader>gsp    - Stash pop",
    "  <leader>gsl    - Stash list",
    "",
    "Push/Pull:",
    "  <leader>gp     - Push (with options)",
    "  <leader>gP     - Pull",
    "  <leader>gf     - Fetch",
    "",
    "Other:",
    "  <leader>gst    - Status",
    "  <leader>gbl    - Blame",
    "  <leader>gg     - LazyGit",
    "  <leader>gd     - Diffview",
    "  <leader>gu     - Unstage",
    "  <leader>gR     - Reset file",
    "",
    "Gitsigns (hunks):",
    "  <leader>hs     - Stage hunk",
    "  <leader>hr     - Reset hunk",
    "  ]c / [c        - Next/prev hunk",
  }
  vim.api.nvim_echo(vim.tbl_map(function(line)
    return { line, "Normal" }
  end, help_lines), true, {})
end, {})

