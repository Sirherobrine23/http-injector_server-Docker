# ZSH Theme - Based on Bira, influenced by Solus.

if [[ $UID -eq 0 ]]; then
    local user_symbol='%F{196}#%f'
else
    local user_symbol='%F{214}$%f'
fi

local return_code="%(?..%F{196}%? ↵%f)"
local user_host='%F{81}%n%f%F{245}@%F{206}%m%f '
local current_dir='%F{245}%~ %b%f'
local git_branch='$(git_prompt_info)'
local rvm_ruby='$(ruby_prompt_info)'
local venv_prompt='$(virtualenv_prompt_info)'

ZSH_THEME_RVM_PROMPT_OPTIONS="i v g"

PROMPT="╭─${user_host}${current_dir}${rvm_ruby}${git_branch}
╰─➤ ${venv_prompt} ${user_symbol} "

RPROMPT="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%F{220}% ‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="›%f"

ZSH_THEME_RUBY_PROMPT_PREFIX="%F{154}% ("
ZSH_THEME_RUBY_PROMPT_SUFFIX=")%f"

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%F{202}% ("
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX=")%f"
ZSH_THEME_VIRTUALENV_PREFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX
ZSH_THEME_VIRTUALENV_SUFFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX