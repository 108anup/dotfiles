#!/usr/bin/env bash

# set -x

FULLPATH=$(realpath $0)
BASEDIR=$(dirname $FULLPATH)
echo "BASEDIR: $BASEDIR"
cd $HOME

declare -A links
# links[".dircolors"]="$HOME/.dircolors"
links[".condarc"]="$HOME/.condarc"
links["sshrc"]="$HOME/.ssh/rc"

declare -A to_install
remote=""
remote=$1

if [[ $remote == "remote" ]]; then
    to_install+=(
        ["base16"]=true
        ["zsh"]=true
        ["ohmyzsh"]=true
        ["tmux"]=true
        ["conda"]=true
        ["rust"]=true
    )
else
    to_install+=(
        ["apps"]=true
        ["fonts"]=true
        ["emacs"]=true
        ["base16"]=true
        ["alacritty"]=true
        ["zsh"]=true
        ["ohmyzsh"]=true
        ["i3"]=true
        ["tmux"]=true
        ["conda"]=true
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

if [[ $UNAME == "Linux" ]] && command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y build-essential curl git g++ gcc tree htop net-tools python3
else
    echo "ERROR: Only apt package manager supported currently. You many need to install build-essential and similar packages manually."
fi

if ! command -v i3 &> /dev/null && [[ ${to_install["i3"]} = true ]]; then
    sudo apt install -y i3 polybar blueman pavuctrl
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
        sudo apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
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
        links+=( ["alacritty.toml"]="$HOME/.config/alacritty/alacritty.toml" )
        mkdir -p $HOME/.config/alacritty
    else
        echo "ERROR: Alacritty is not installed"
    fi
fi

# if ! command -v redshift-gtk &> /dev/null && [[ ${to_install["redshift"]} = true ]]; then
#     sudo apt install redshift-gtk
#     if command -v redshift -h > /dev/null; then
# 	      echo "redshift is installed"
# 	      mkdir -p $HOME/.config/redshift
# 	      links+=( ["redshift.conf"]="$HOME/.config/redshift/redshift.conf" )
#     else
# 	      echo "ERROR: Unable to install redshift"
#     fi
# fi

if ! command -v zsh &> /dev/null && [[ ${to_install["zsh"]} = true ]]; then
    if [[ $UNAME == "Linux" ]] && command -v apt &> /dev/null; then
        sudo apt install -y zsh
    else
        echo "Only apt package manager supported currently. Please install zsh manually."
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
    links+=(
        [".zshrc"]="$HOME/.zshrc"
        [".oh-my-zsh-custom"]="$HOME/.oh-my-zsh-custom"
    )
else
    echo "Skipping ohmyzsh installation as zsh is not installed."
fi

if ! command -v tmux &> /dev/null && [[ ${to_install["tmux"]} = true ]]; then
    if [[ $UNAME == "Linux" ]] && command -v apt &> /dev/null; then
        sudo apt install -y tmux
    else
        echo "Only apt package manager supported currently. Please install tmux manually."
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
    if [[ $UNAME == "Linux" ]] && command -v apt &> /dev/null; then
        sudo apt install -y emacs
    else
        echo "Only apt package manager supported currently. Please install emacs manually."
    fi
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
        wget https://github.com/adobe-fonts/source-code-pro/releases/download/2.042R-u%2F1.062R-i%2F1.026R-vf/OTF-source-code-pro-2.042R-u_1.062R-i.zip
        unzip OTF-source-code-pro-2.042R-u_1.062R-i.zip

        # Source sans pro (presentations)
        wget https://github.com/adobe-fonts/source-sans/releases/download/3.052R/OTF-source-sans-3.052R.zip
        unzip OTF-source-sans-3.052R.zip

        # Source serif pro
        wget https://github.com/adobe-fonts/source-serif/releases/download/4.005R/source-serif-4.005_Desktop.zip
        unzip source-serif-4.005_Desktop.zip
        cp source-serif-*/OTF/*.otf $fontpath

        cp OTF/*.otf $fontpath
        sudo cp $fontpath /usr/local/share/fonts/  # the snap version of vscode does not look at user fonts it seems.
        fc-cache -f -v

        # Siji (polybar)
        git clone https://github.com/stark/siji && cd siji
        ./install.sh
        # https://github.com/stark/siji/issues/28
        echo "WARN: If siji does not work, 'sudo rm /etc/fonts/70-no-bitmaps.conf'"

        # Successfully installed siji.pcf -> /home/anupa/.local/share/fonts
        # Add the following snippet in your custom startup script that gets executed during xlogin:

        #     xset +fp /home/anupa/.local/share/fonts
        #     xset fp rehash

        rm -fr ~/tmp-fonts
        cd $cur_dir

        # Unifont and noto color emoji (polybar)
        sudo apt install -y unifont fonts-noto-color-emoji
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
    sudo apt-key add - && sudo apt update && sudo apt install -y yandex-disk
    echo "INFO: 'yandex-disk setup' manually"
fi


if [[ ${to_install["apps"]} == "true" ]]; then
    if command -v snap &> /dev/null; then
        sudo snap install slack todoist zoom-client
        sudo snap install code --classic
        # sudo snap install notion-desktop
    else
        echo "ERROR: snap not installed. Please install manually."
    fi
    if [[ $UNAME == "Linux" ]] && command -v apt &> /dev/null; then
        sudo apt install -y texlive-full openssh-server
    else
        echo "ERROR: Only apt package manager supported currently. Please install texlive-full and openssh-server manually."
    fi
    echo "WARN: Install albert, picom or xcompgr manually."
    # https://software.opensuse.org/download.html?project=home:manuelschneid3r&package=albert
    # echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/home:manuelschneid3r.list
    # curl -fsSL https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_manuelschneid3r.gpg > /dev/null
    # sudo apt update
    # sudo apt install albert
fi


for l in ${!links[@]}; do
    make_link ${l} ${links[${l}]}
done

# TODO: Currently on first install, zshrc link does not happen properly, and so
# the conda config goes to unlinked zshrc.

# TODO: Also on first install, the rust zsh config does not get populated.

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
