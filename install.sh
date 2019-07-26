#!/usr/bin/env bash

BASEDIR=$(dirname $0)
echo "BASEDIR: $BASEDIR"

cd $HOME

if [[ -d "$HOME/.emacs.d" ]]; then
    echo "Directory $HOME/.emacs.d already exists, assuming spacemacs installation"
else
    git clone https://github.com/syl20bnr/spacemacs $HOME/.emacs.d
fi

if [[ -z $(zsh --version) ]]; then
    echo "Please install zsh"
    exit 1
fi

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "Directory $HOME/.oh-my-zsh already exists, assuming oh-my-zsh installation"
else
    sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

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
        ln -sT "$BASEDIR/$1" $2
        set +x
    else
        echo "Found existing file/link for dst: $2"
    fi
    set +u
}

declare -A links

links[".spacemacs.d"]="$HOME/.spacemacs.d"
links+=( [".tmux.conf"]="$HOME/.tmux.conf" \
                       [".zshrc"]="$HOME/.zshrc" \
                       [".oh-my-zsh-custom"]="$HOME/.oh-my-zsh-custom" \
                       [".i3"]="$HOME/.i3" )

for l in ${!links[@]}; do
    make_link ${l} ${links[${l}]}
done

if ! exists "$BASEDIR/.spacemacs.d/custom.el"; then
    cp "$BASEDIR/.spacemacs.d/custom-template.el" "$BASEDIR/.spacemacs.d/custom.el"
fi
