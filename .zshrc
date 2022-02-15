[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

UNAME=$(uname -s)
IDENTITIES=""
if [[ $UNAME == "Darwin" ]]; then
    IDENTITIES=($(find $HOME/.ssh -type f -name "*rsa*" -not -name "*.pub" -exec basename {} \;))
    IDENTITIES+=($(find $HOME/.ssh -type f -name "*ed25519*" -not -name "*.pub" -exec basename {} \;))
else
    # From https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/ssh-agent
    IDENTITIES=($(find $HOME/.ssh -type f -name "*rsa*" -not -name "*.pub" -printf "%f\n"))
    IDENTITIES+=($(find $HOME/.ssh -type f -name "*ed25519*" -not -name "*.pub" -printf "%f\n"))
fi

zstyle :omz:plugins:ssh-agent identities ${IDENTITIES[@]}

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="time-robb"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.oh-my-zsh-custom

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(jump colored-man-pages zsh-autosuggestions ssh-agent fzf-zsh-plugin)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

EDITOR='emacs'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Get all unicode symbols
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Xilinx License
# export XILINXD_LICENSE_FILE="2101@xilinx-lic.ece.cmu.edu"


tmux_kill_detached(){
    tmux list-sessions | grep -v "attached" | awk 'BEGIN{FS=":"}{print $1}' | xargs -n 1 tmux kill-session -t
}

turbo_off_fn(){
    echo "1" > /sys/devices/system/cpu/intel_pstate/no_turbo
}

turbo_on_fn(){
    echo "0" > /sys/devices/system/cpu/intel_pstate/no_turbo
}

local_forward(){
    host=$1
    port=$2
    if [[ -z $host ]] || [[ -z $port ]]; then
        echo "Usage: local_forward HOST PORT"
    fi
    ssh -nNL ${port}:localhost:${port} ${host}
}

# Custom Aliases
if type exa > /dev/null; then
    alias ls="exa"
    alias l="exa -lah -a"
    alias la="exa -lah"
    alias ll="exa -lh"
else
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
fi

alias turbo_on='bash -c "$(declare -f turbo_on_fn); turbo_on_fn"'
alias turbo_off='bash -c "$(declare -f turbo_off_fn); turbo_off_fn"'

alias emacsc="emacsclient -a '' -c"
alias sudo="sudo "

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
    eval "$("$BASE16_SHELL/profile_helper.sh")"

# TMUX
# If not running interactively, do not do anything
# [[ $- != *i* ]] && return
# if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ tmux ]] && [[ ! "$TERM" =~ eterm-color ]] && [ -z "$TMUX" ]; then
#   exec tmux -2
# fi

UNAME=$(uname -s)
if [[ $UNAME == "Linux" ]]; then
    eval "$(dircolors ~/.dircolors)";
fi

# Same completion colors when using cd as with ls.
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:*:*:*' menu yes select

# if [[ "$TERM" == "dumb" ]]
# then
#     unsetopt zle
#     unsetopt prompt_cr
#     unsetopt prompt_subst
#     unfunction precmd
#     unfunction preexec
#     PS1='$ '
# fi

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh # use plugin instead

# Allow local customizations in the ~/.shell_local_after file
if [ -f ~/.shell_local_after ]; then
    source ~/.shell_local_after
fi

# ================ ANY TEXT AFTER THIS IS ADDED BY AUTO-GENERATED TOOLS ================
# ================ SUCH TEXT WILL BE MOVED TO $HOME/.zshenv             ================
