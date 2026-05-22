local M = {}

M.setup = function()
    vim.opt.guicursor = {
        "n-v-c:block-Cursor",
        "i-ci-ve:ver25-Cursor",
        "r-cr:hor20-Cursor"
    }

    vim.cmd([[
    highlight Cursor guifg=white guibg=red
    highlight lCursor guifg=white guibg=red
    ]])
end

return M

