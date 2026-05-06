-- =========================
-- ЦВЕТА КУРСОРА ДЛЯ NEOVIM (iTerm2)
-- =========================

if vim.env.TERM_PROGRAM == "iTerm.app" then
    local function set_cursor_color(color)
        local esc = string.format("\027]12;%s\007", color)
        io.stderr:write(esc)
        io.stderr:flush()
    end

    -- Форма курсора (исправленная версия)
    vim.o.guicursor = "n:block-blinkon100"
    vim.o.guicursor = vim.o.guicursor .. ",i:ver25-blinkon100"
    vim.o.guicursor = vim.o.guicursor .. ",r:hor20-blinkon100"

    -- Цвета по режимам
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function() set_cursor_color("green") end,
    })

    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function() set_cursor_color("green") end,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function() 
            if vim.fn.mode() == "R" then
                set_cursor_color("orange")
            else
                set_cursor_color("red")
            end
        end,
    })

    vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*:*",
        callback = function()
            local mode = vim.fn.mode()
            if mode:find("[vV\x16]") then  -- Visual режимы
                set_cursor_color("yellow")
            elseif mode == "R" then  -- Replace режим
                set_cursor_color("orange")
            elseif mode == "i" or mode == "I" then  -- Insert режим
                set_cursor_color("red")
            else  -- Normal режим
                set_cursor_color("green")
            end
        end,
    })

    -- При выходе из Neovim
    vim.api.nvim_create_autocmd("VimLeave", {
        callback = function() set_cursor_color("green") end,
    })
end
