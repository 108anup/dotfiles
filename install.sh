#!/usr/bin/env bash

FULLPATH=$(realpath $0)
BASEDIR=$(dirname $FULLPATH)
echo "BASEDIR: $BASEDIR"
cd $HOME

declare -A links
links[".dircolors"]="$HOME/.dircolors"
links[".condarc"]="$HOME/.condarc"

declare -A to_install
to_install+=(
    ["emacs"]=true
    ["base16"]=true
    ["alacritty"]=true
    ["zsh"]=true
    ["i3"]=true
    ["tmux"]=true
)

remote=""
remote=$1

if [[ $remote == "remote" ]]; then
    to_install["emacs"]=false
    to_install["base16"]=false
    to_install["alacritty"]=false
    to_install["i3"]=false
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
        ln -s "$BASEDIR/$1" $2
        set +x
    else
        echo "Found existing file/link for dst: $2"
    fi
    set +u
}

UNAME=$(uname -s)
echo "OS: $UNAME"
if [[ $UNAME == "Darwin" ]] && [[ $1 == "firstrun" ]]; then
    if command -v brew &> /dev/null; then
        $BASEDIR/brew.sh
    fi
fi

if command -v i3 &> /dev/null && [[ $UNAME == "Linux" ]] && [[ ${to_install["i3"]} = true ]]; then
    echo "i3 is installed"
    links+=( [".i3"]="$HOME/.i3" )
    if command -v polybar &> /dev/null && [[ $UNAME == "Linux" ]]; then
        echo "polybar is installed"
        links+=( ["polybar.ini"]="$HOME/.config/polybar/config" )
        mkdir -p $HOME/.config/polybar
    else
        echo "WARN: i3 bar won't work properly.\ni3 is installed and polybar is not installed"
    fi
fi

if command -v alacritty > /dev/null && [[ ${to_install["alacritty"]} = true ]]; then
    echo "alacritty is installed"
    links+=( ["alacritty.yml"]="$HOME/.config/alacritty/alacritty.yml" )
    mkdir -p $HOME/.config/alacritty
else
    echo "Alacritty not installed, it needs to be installed manually"
    # https://github.com/alacritty/alacritty
fi

if command -v zsh &> /dev/null && [[ ${to_install["zsh"]} = true ]]; then
    echo "zsh is installed"
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "Directory $HOME/.oh-my-zsh already exists, assuming oh-my-zsh installation"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        mv $HOME/.zshrc $HOME/.zshrc.oh-my-zsh.bkp
    fi
    links+=( [".zshrc"]="$HOME/.zshrc" \
                       [".oh-my-zsh-custom"]="$HOME/.oh-my-zsh-custom" )
else
    echo "Please install zsh"
fi

if command -v tmux &> /dev/null && [[ ${to_install["tmux"]} = true ]]; then
    echo "tmux is installed"
    links+=( [".tmux.conf"]="$HOME/.tmux.conf" )
else
    echo "Please install tmux"
fi
echo "Please manually initialize plugins using:\n $> git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"

if command -v emacs &> /dev/null && [[ ${to_install["emacs"]} = true ]]; then
    echo "emacs is installed"
    if [[ -e "$HOME/.emacs.d/spacemacs.mk" ]]; then
        echo "$HOME/.emacs.d/spacemacs.mk already exists, assuming spacemacs installation"
    else
        if [[ -d "$HOME/.emacs.d" ]]; then
            mv $HOME/.emacs.d $HOME/.emacs.d.bkp
        fi
        if [[ -e "$HOME/.emacs" ]]; then
            mv $HOME/.emacs $HOME/.emacs.bkp
        fi
        git clone https://github.com/syl20bnr/spacemacs $HOME/.emacs.d
    fi

    if ! exists "$BASEDIR/.spacemacs.d/custom.el"; then
        cp "$BASEDIR/.spacemacs.d/custom-template.el" "$BASEDIR/.spacemacs.d/custom.el"
    fi
    links[".spacemacs.d"]="$HOME/.spacemacs.d"
else
    echo "Please install emacs"
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
