syntax on

" Настройки курсора для iTerm2
if $TERM_PROGRAM == "iTerm.app"
    " === ФОРМА курсора ===
    " Мигающий прямоугольник в режиме вставки (Insert mode)
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    " Не мигающий прямоугольник в нормальном режиме (Normal mode)
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
    " Блочный курсор в режиме замены (Replace mode)
    let &t_SR = "\<Esc>]50;CursorShape=2\x7"
    
    " === ЦВЕТ курсора ===
    " Режим вставки — КРАСНЫЙ
    let &t_SI .= "\<Esc>]12;red\x7"
    " Обычный режим — ЗЕЛЕНЫЙ (или любой другой по твоему выбору)
    let &t_EI .= "\<Esc>]12;green\x7"
    " Режим замены — ОРАНЖЕВЫЙ
    let &t_SR .= "\<Esc>]12;orange\x7"
    
    " Возвращаем обычный цвет при выходе из Vim
    autocmd VimLeave * silent !echo -ne "\033]12;green\x7"
endif

" Дополнительные настройки для надежности
set ttimeout
set ttimeoutlen=1
set ttyfast
