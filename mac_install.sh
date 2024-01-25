#!/usr/bin/env bash

# TODO: Remove redundancies between the two install scripts.

# set -x

FULLPATH=$(realpath $0)
BASEDIR=$(dirname $FULLPATH)
echo "BASEDIR: $BASEDIR"
cd $HOME

declare -A links
links[".condarc"]="$HOME/.condarc"

declare -A to_install
remote=""
remote=$1

if [[ $remote == "remote" ]]; then
    to_install+=(
	      ["emacs"]=true
	      ["base16"]=true
	      ["ohmyzsh"]=true
	      ["tmux"]=true
	      ["conda"]=true
	      ["rust"]=true
    )
else
    to_install+=(
	      ["emacs"]=true
	      ["base16"]=true
	      ["ohmyzsh"]=true
	      ["tmux"]=true
	      ["conda"]=true
	      ["fonts"]=true
	      ["apps"]=true
	      ["yandex"]=true
	      ["rust"]=true
    )
fi

echo ${!to_install[@]}

exists(){
    [[ -d $1 ]] || [[ -f $1 ]]
}

is_broken_link(){
    [[ -L $1 ]] && [[ ! -a $1 ]]
}

make_link(){
    set -u
    if ! exists $2 || is_broken_link $2; then
        echo "Making link: src: $1, dst: $2"
        rm -fr $2
        set -x
        ln -s "$BASEDIR/$1" $2
        set +x
    else
        echo "Found existing file/link for dst: $2"
    fi
    set +u
}

UNAME=$(uname -s)
echo "OS: $UNAME"
if [[ $UNAME != "Darwin" ]]; then
    echo "ERROR: Only Mac OS supported for this script."
    exit 1
fi

if [[ ${to_install["rust"]} = true ]]; then
    if ! command -v cargo &> /dev/null; then
        # Install rust
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
    fi
    if ! command -v exa &> /dev/null; then
        cargo install exa
    fi
fi

if command -v zsh &> /dev/null && [[ ${to_install["ohmyzsh"]} = true ]]; then
    echo "zsh is installed"
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "Directory $HOME/.oh-my-zsh already exists, assuming oh-my-zsh installation"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        # mv $HOME/.zshrc $HOME/.zshrc.oh-my-zsh.bkp
    fi
    links+=( [".zshrc"]="$HOME/.zshrc" \
                       [".oh-my-zsh-custom"]="$HOME/.oh-my-zsh-custom" )
else
    echo "Skipping ohmyzsh installation as zsh is not installed."
fi

if command -v tmux &> /dev/null && [[ ${to_install["tmux"]} = true ]]; then
    echo "tmux is installed"
    links+=( [".tmux.conf"]="$HOME/.tmux.conf" )
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        echo "tmux plugin manager is already installed. If needed, reload config (Prefix + r) and install plugins (Prefix + I)."
    else
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        echo "Reload config (Prefix + r) and install plugins (Prefix + I)."
    fi
else
    echo "Not linking tmux config as tmux is not installed."
fi

if [[ ${to_install["base16"]} = true ]]; then
    if [[ -d "$HOME/.config/base16-shell" ]]; then
        echo "Directory $HOME/.config/base16-shell/ already exists, assuming base16 installation for shell"
    else
        git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
    fi
fi

for l in ${!links[@]}; do
    make_link ${l} ${links[${l}]}
done

if [[ ${to_install["conda"]} = true ]]; then
    if [[ -d "/opt/homebrew/Caskroom/miniconda" ]]; then
        echo "Assuming miniconda is installed"
        if [[ -d "/opt/homebrew/Caskroom/miniconda/base/envs/wbase" ]]; then
            echo "Assuming wbase conda env is installed"
        else
            conda init "$(basename "${SHELL}")"
            conda create -yn wbase python=3 numpy scipy jupyter matplotlib pip
            conda activate wbase
            echo -e "\nconda activate wbase" >> $HOME/.zshrc
        fi
    else
        echo "conda needs to be installed via brew"
    fi
fi

$BASEDIR/clean_zshrc.sh

# set +x
