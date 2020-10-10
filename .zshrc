# Start configuration added by Zim install {{{
#
# User configuration sourced by interactive shells
#

# -----------------
# Zsh configuration
# -----------------

#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}


# --------------------
# Module configuration
# --------------------

#
# completion
#

# Set a custom path for the completion dump file.
# If none is provided, the default ${ZDOTDIR:-${HOME}}/.zcompdump is used.
#zstyle ':zim:completion' dumpfile "${ZDOTDIR:-${HOME}}/.zcompdump-${ZSH_VERSION}"

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

#
# zsh-autosuggestions
#

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=10'

# ------------------
# Initialize modules
# ------------------

if [[ ${ZIM_HOME}/init.zsh -ot ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  # Update static initialization script if it's outdated, before sourcing it
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Bind up and down keys
zmodload -F zsh/terminfo +p:terminfo
if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
  bindkey ${terminfo[kcuu1]} history-substring-search-up
  bindkey ${terminfo[kcud1]} history-substring-search-down
fi

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# }}} End configuration added by Zim install

# Created by newuser for 5.8

#esto nos permite ejecutar funciones en el prompt
setopt PROMPT_SUBST

alias sudo="sudo "
alias ll="ls -l"
alias la="ls -la"
alias cdc="cd $HOME/Code"
alias gs="git status"
alias code="/usr/local/bin/code"



#========================================================================
#			   exportamos variable
#========================================================================
#estamos convinando el directorio del binario donde se instala git
#La variable Global PATH nos dice : "Oye, cuando voy a estar en mi terminal"
#"que sepa que dentro de esta carpeta hay N° binarios que tu puedas ejecutar"
#"algo como si fuera de primer nivel y siempre tendremos preferencia"
export PATH="/usr/local/bin/:$PATH"

#------------------------------------------------------------------------


#========================================================================
#	    funcion mapeada que  ejecta el comando (ls | fzf)
#========================================================================

#todo se listara con la funcion ls, seran directorios
#pasamos la informacion de ls a fzf (ls -ad */ | fzf)
#esto nos los devuelve como output , lo capturamos y lo guardamos
#en  una variable dirtomove

_display_message() {
	dirtomove=$(ls -ad */ | fzf)
  cd "$dirtomove"
}

zle	-N	_display_message
bindkey '^h'	_display_message

#------------------------------------------------------------------------




#========================================================================
#		     Reverse Search + FZF = Productividad
#========================================================================

# Convinamos la Busqueda Inversa en el historial de Comandos con FzF que es
# un LS(list) Vitaminado produciendo interactividad

_reverse_search() {
	local selected_command=$(fc -rl 1 | awk '{$1="";print substr($0,2)}' | fzf)
	LBUFFER=$selected_command
}

zle	-N	_reverse_search
bindkey '^r'	_reverse_search

#------------------------------------------------------------------------

# Fzf Completion
#/usr/share/fzf/completion.zsh
#/usr/share/fzf/shell/key-bindings.zsh

#========================================================================
#			Comando que Enlaza fzf con zsh
#========================================================================
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#------------------------------------------------------------------------



#========================================================================
#			    	gc (git commit)
#========================================================================
function gc {
  git add -A

  if [ -z "$1" ]; then
    git commit - S
  else
    git commit -S -m"$1"
  fi
}



#========================================================================
#             Funcion que nos indica el estado de git
#========================================================================
function git_prompt_info {
  inside_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"

  if [ "$inside_git_repo" ]; then
    current_branch=$(git branch --show-current)
    print -P " on %{%F{yellow}%}$current_branch%{%f%}"
  else
    echo ""
  fi
}

#----------------------------------------------------------------------




#========================================================================
#			    Customizando Prompt
#========================================================================

# el prompt llama a las funciones prompt_exit_code() y git_prompt_info
# la primer funcion nos pintara de Rojo cuando es un 1 y verde si es 0
# en funcion git estus
function prompt_exit_code() {
  local EXIT="$?"

  if [ $EXIT -eq 0 ]; then
    echo -n green
  else
    echo -n red
  fi
}

PROMPT='%{%F{$(prompt_exit_code)}%}%n%{%f%} @ %2d$(git_prompt_info): '

#------------------------------------------------------------------------




#======================================================================
#                             PROGRESS BAR
#======================================================================
progress-bar() {
  local duration=${1}


    already_done() { for ((done=0; done<$elapsed; done++)); do printf "▇"; done }
    remaining() { for ((remain=$elapsed; remain<$duration; remain++)); do printf " "; done }
    percentage() { printf "| %s%%" $(( (($elapsed)*100)/($duration)*100/100 )); }
    clean_line() { printf "\r"; }

  for (( elapsed=1; elapsed<=$duration; elapsed++ )); do
      already_done; remaining; percentage
      sleep 1
      clean_line
  done
  clean_line
}

#----------------------------------------------------------------------

