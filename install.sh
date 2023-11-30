#!/usr/bin/env bash

# set -x

FULLPATH=$(realpath $0)
BASEDIR=$(dirname $FULLPATH)
echo "BASEDIR: $BASEDIR"
cd $HOME

declare -A links
# links[".dircolors"]="$HOME/.dircolors"
links[".condarc"]="$HOME/.condarc"

declare -A to_install
remote=""
remote=$1

if [[ $remote == "remote" ]]; then
    to_install+=(
	      ["emacs"]=true
	      ["base16"]=true
	      ["zsh"]=true
	      ["ohmyzsh"]=true
	      ["tmux"]=true
	      ["conda"]=true
	      ["rust"]=true
    )
else

    # to_install+=(
    #     ["emacs"]=true
    #     ["spacemacs"]=true
    #     ["base16"]=true
    #     ["alacritty"]=true
    #     ["zsh"]=true
    #     ["ohmyzsh"]=true
    #     ["i3"]=true
    #     ["tmux"]=true
    #     ["redshift"]=true
    #     ["conda"]=true
    # )

    to_install+=(
	      ["emacs"]=true
	      ["base16"]=true
	      ["alacritty"]=true
	      ["zsh"]=true
	      ["ohmyzsh"]=true
	      ["i3"]=true
	      ["tmux"]=true
	      ["redshift"]=true
	      ["conda"]=true
	      ["fonts"]=true
	      ["apps"]=true
	      ["yandex"]=true
	      ["rclone"]=true
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
if [[ $UNAME == "Darwin" ]]; then
    echo "Please use mac_install.sh."
    exit 1
fi

if [[ $UNAME == "Linux" ]] && command -v apt-get &> /dev/null; then
    sudo apt-get update > /dev/null
    sudo apt-get install -y build-essential curl git g++ gcc tree htop net-tools python3 > /dev/null
else
    echo "ERROR: Only apt-get package manager supported currently. You many need to install build-essential and similar packages manually."
fi

if ! command -v i3 &> /dev/null && [[ ${to_install["i3"]} = true ]]; then
    sudo apt-get install i3 polybar blueman pavuctrl
    if command -v i3 &> /dev/null && [[ $UNAME == "Linux" ]]; then
	      echo "i3 is installed"
	      links+=( [".i3"]="$HOME/.i3" )
	      if command -v polybar &> /dev/null && [[ $UNAME == "Linux" ]]; then
            echo "polybar is installed"
            links+=( ["polybar.ini"]="$HOME/.config/polybar/config" )
            mkdir -p $HOME/.config/polybar
	      else
            echo "ERROR: i3 bar won't work properly."
	          echo "ERROR: i3 is installed and polybar is not installed"
	      fi
    else
	      echo "ERROR: Unable to install i3."
    fi
fi

if [[ ${to_install["rust"]} = true ]]; then
    if ! command -v cargo &> /dev/null; then
        sudo apt-get install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
        # Install rust
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
    fi
    if ! command -v exa &> /dev/null; then
        cargo install exa
    fi
fi

if [[ ${to_install["alacritty"]} = true ]]; then
    if ! command -v alacritty &> /dev/null; then
	      cargo install alacritty
	      sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $(which alacritty) 50
	      echo "Run if still not default: sudo update-alternatives --config x-terminal-emulator"
    fi
    if command -v alacritty > /dev/null; then
	      echo "alacritty is installed"
	      links+=( ["alacritty.yml"]="$HOME/.config/alacritty/alacritty.yml" )
	      mkdir -p $HOME/.config/alacritty
    else
	      echo "ERROR: Alacritty is not installed"
    fi
fi

if ! command -v redshift-gtk &> /dev/null && [[ ${to_install["redshift"]} = true ]]; then
    sudo apt-get install redshift-gtk
    if command -v redshift -h > /dev/null; then
	      echo "redshift is installed"
	      mkdir -p $HOME/.config/redshift
	      links+=( ["redshift.conf"]="$HOME/.config/redshift/redshift.conf" )
    else
	      echo "ERROR: Unable to install redshift"
    fi
fi

if ! command -v zsh &> /dev/null && [[ ${to_install["zsh"]} = true ]]; then
    if [[ $UNAME == "Linux" ]] && command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y zsh
    else
        echo "Only apt-get package manager supported currently. Please install zsh manually."
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

if ! command -v tmux &> /dev/null && [[ ${to_install["tmux"]} = true ]]; then
    if [[ $UNAME == "Linux" ]] && command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y tmux
    else
        echo "Only apt-get package manager supported currently. Please install tmux manually."
    fi
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

if ! command -v emacs &> /dev/null && [[ ${to_install["emacs"]} = true ]]; then
    if [[ $UNAME == "Linux" ]] && command -v apt-get &> /dev/null; then
        sudo add-apt-repository -y ppa:kelleyk/emacs
        sudo apt-get update
        sudo apt-get install -y emacs28
        echo "Rerun script to install spacemacs"
    else
        echo "Only apt-get package manager supported currently. Please install emacs manually."
    fi
fi

if command -v emacs &> /dev/null && [[ ${to_install["spacemacs"]} = true ]]; then
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
    echo "Skipping spacemacs installation as emacs is not installed"
fi

if [[ ${to_install["base16"]} = true ]]; then
    if [[ -d "$HOME/.config/base16-shell" ]]; then
        echo "Directory $HOME/.config/base16-shell/ already exists, assuming base16 installation for shell"
    else
        git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
    fi
fi

if [[ ${to_install["fonts"]} = true ]]; then
    # https://askubuntu.com/questions/193072/how-to-use-the-adobe-source-code-pro-font
    ls ~/.local/share/fonts/ | grep SourceCodePro > /dev/null
    found=$?
    if [[ $found != 0 ]]; then
	      fontpath="${XDG_DATA_HOME:-$HOME/.local/share}"/fonts
	      mkdir -p $fontpath

	      cur_dir = $(pwd)
	      mkdir ~/tmp-fonts
	      cd ~/tmp-fonts

	      # Source code pro (editor)
	      wget https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip
	      unzip 1.050R-it.zip
	      cp source-code-pro-*-it/OTF/*.otf $fontpath

	      # Source serif pro
	      wget https://github.com/adobe-fonts/source-serif-pro/archive/2.000R.zip
	      unzip 2.000R.zip
	      cp source-serif-*R/OTF/*.otf $fontpath

	      # Source sans pro (presentations)
	      wget https://github.com/adobe-fonts/source-sans-pro/archive/2.020R-ro/1.075R-it.zip
	      unzip 1.075R-it.zip
	      cp source-sans-*-it/OTF/*.otf $fontpath
	      
	      fc-cache -f -v

	      # Siji (polybar)
	      git clone https://github.com/stark/siji && cd siji
	      ./install.sh
	      # https://github.com/stark/siji/issues/28
	      echo "WARN: If siji does not work, 'sudo rm /etc/fonts/70-no-bitmaps.conf'"

	      rm -fr ~/tmp-fonts
	      cd $cur_dir

	      # Unifont and noto color emoji (polybar)
	      sudo apt-get install -y unifont fonts-noto-color-emoji
    else
	      echo "Fonts already installed."
    fi

fi

if ! command -v rclone &> /dev/null && [[ ${to_install["rclone"]} == "true" ]]; then
    sudo -v ; curl https://rclone.org/install.sh | sudo bash
    echo "TODO: 'rclone config' manually"
    echo "TODO: setup cron entry manually 'rclone bisync box:BoxSync ~/BoxSync -vvv --log-file ~/.rclone-box-bisync."
fi

if ! command -v yandex-disk &> /dev/null && [[ ${to_install["yandex"]} == "true" ]]; then
    echo "deb http://repo.yandex.ru/yandex-disk/deb/ stable main" | \
	      sudo tee -a /etc/apt/sources.list.d/yandex-disk.list > /dev/null && wget http://repo.yandex.ru/yandex-disk/YANDEX-DISK-KEY.GPG -O- | \
	          sudo apt-key add - && sudo apt-get update && sudo apt-get install -y yandex-disk
    echo "INFO: 'yandex-disk setup' manually"
fi


if [[ ${to_install["apps"]} == "true" ]]; then
    # sudo snap install notion-snap slack todoist  # Only on Ubuntu 22.04 onwards.

    if ! command -v teams &> /dev/null; then
	      # Install teams
	      curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
	      sudo sh -c \
	           'echo "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main" > /etc/apt/sources.list.d/teams.list'
	      sudo apt-get update
	      sudo apt-get install teams
    fi

    if ! command -v code &> /dev/null; then
	      sudo apt-get install wget gpg
	      wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	      sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
	      sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	      rm -f packages.microsoft.gpg
	      sudo apt-get install apt-transport-https
	      sudo apt-get update
	      sudo apt-get install code # or code-insiders
    fi

    if ! command -v zoom &> /dev/null; then
	      sudo wget https://zoom.us/client/latest/zoom_amd64.deb
	      sudo apt-get install ./zoom_amd64.deb
	      rm -fr ./zoom_amd64.deb
    fi

    echo "WARN: Install albert, latex, ssh-server manually."
fi

# https://software.opensuse.org/download.html?project=home:manuelschneid3r&package=albert
# echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/home:manuelschneid3r.list
# curl -fsSL https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_manuelschneid3r.gpg > /dev/null
# sudo apt-get update
# sudo apt-get install albert

# https://tug.org/texlive/quickinstall.html
# cd /tmp # working directory of your choice
# wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
# zcat install-tl-unx.tar.gz | tar xf -
# cd install-tl-*
# perl ./install-tl --no-interaction

# sudo apt-get install openssh-server

for l in ${!links[@]}; do
    make_link ${l} ${links[${l}]}
done

# Install conda after zshrc is updated...
if [[ ${to_install["conda"]} = true ]]; then
    if [[ -d "$HOME/miniconda3" ]]; then
        echo "Directory $HOME/miniconda3 already exists, assuming conda installation"
    else
        cd /tmp
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        chmod u+x ./Miniconda3-latest-Linux-x86_64.sh
        ./Miniconda3-latest-Linux-x86_64.sh -b -u
        rm ./Miniconda3-latest-Linux-x86_64.sh
        cd $HOME

        eval "$($HOME/miniconda3/bin/conda shell.zsh hook)"
        conda init zsh
        conda create -yn wbase python=3 numpy scipy jupyter matplotlib pip
        conda activate wbase
        echo -e "\nconda activate wbase" >> $HOME/.zshrc
    fi
fi


$BASEDIR/clean_zshrc.sh

# set +x
