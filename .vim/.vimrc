
" ALE config

let g:ale_lint_on_save          = 1
let g:ale_lint_on_enter         = 1
let g:ale_set_quickfix          = 1
let g:ale_lint_on_text_changed  = 1
let g:ale_lint_on_insert_leave  = 1


let g:ale_ruby_rubocop_executable = 'bundle'
let g:ale_ruby_solargraph_executable = 'bundle'
let g:ale_echo_msg_format = '[%linter%] [%severity%] %s [%code%]'

echo 'project level vimrc loaded'
