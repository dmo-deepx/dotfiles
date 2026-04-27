# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html

PROMPT="%{${fg_bold[blue]}%}[ %{${fg_bold[green]}%}%*%{${fg_bold[blue]}%} / %{${fg[cyan]}%}%n@%m%{${fg_bold[blue]}%} ] %{${fg_bold[blue]}%}(%{${fg[red]}%}%?%{${fg_bold[blue]}%}) %{${fg_bold[blue]}%}[ %{${fg[red]}%}%/\$(git_prompt_info)%{${fg[yellow]}%}\$(ruby_prompt_info)%{${fg_bold[blue]}%} ]%{$reset_color%}
 $ "

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="%{${fg_bold[green]}%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="✔"
ZSH_THEME_GIT_PROMPT_DIRTY="✗"
