#!/bin/sh

logging=true
verbose=

# Script core {{{
    colorscheme() {
        reset="$(tput sgr0)$(tput setaf 253)" #grey
        title="$(tput setaf 214)" #orange
        question="$(tput setaf 81)" #darker cyan
        answer="$(tput bold)$(tput setaf 255)" #white
        success="$(tput setaf 2)" #green
        failed="$(tput setaf 1)" #red
        stderr="$(tput setaf 175)" #white
    }

    log_init() {
        logfile=./install-debian-testing.log
        [ "$logging" ] && log "INFO Starting install..." > $logfile
    }

    log() {
        [ "$logging" ] && printf "$(date +"%T") $@\n" >> $logfile
    }

    h1() {
        printf "${title}$@${reset}\n\n"
    }

    p() {
        printf "${reset}$@\n"
    }

    try() { 
        #tput sc
        #printf "${reset}[       ] ${*}..."
        printf "${*} ..."
        if eval_result=$(eval "$@" 2>&1) ; then
            #stty -echo; tput rc; tput cuf 1; stty echo
            #printf "${success}success${reset}\n" 
            [ "$verbose" ] && p "${eval_result}\n"
        else
            #stty -echo; tput rc; tput cuf 1; stty echo
            printf "${failed}failed${reset}"
            printf "${stderr}${eval_result}\n"
            log "ERROR ${*} ${eval_result} ...failed\n"
        fi
    }
# }}}

# Intro {{{
    welcome() {
        h1 "Welcome to setup of $(head -n1 /etc/os-release | sed 's/PRETTY_NAME=//')"
        p "  Kernel: $(uname -r)"
        p "  Machine name:  $(uname -n)"
        p "  Processor type: $(uname -p)\n"
        read -p "  ${question}Continue(y/n)? ${answer}" yn
        [ "$yn" = "n" ] && printf "\n${failed}Aborting.${reset}\n\n" && exit 1 || p
    }

    inputUserName() {
        h1 'Create User'
        read -p "${question}  Username: ${answer}" username; printf "${reset}"
    }

    inputUserPass() {
        printf "${question}  Password: "; stty -echo; read pass1; stty echo; p
        printf "${question}  Re-enter Password: "; stty -echo; read pass2; stty echo; p "\n"
        if ! [ "$pass1" = "$pass2" ]; then
            printf "  ${failed}Passwords do not match. Try again:${reset}\n\n"
            unset pass1 pass2
            inputUserPass
        fi
    }
# }}}

#addSources() {
    #echo "\
    #deb http://deb.debian.org/debian/ testing main
    #deb-src http://deb.debian.org/debian/ testing main
    #
    #deb http://deb.debian.org/debian/ testing-updates main
    #deb-src http://deb.debian.org/debian/ testing-updates main
    #
    #deb http://deb.debian.org/debian-security testing-security main
    #deb-src http://deb.debian.org/debian-security testing-security main
    #" > /etc/apt/sources.list
    #apt update
    #}


debian_prereqs() {
    umask 022
    echo "Set root password:"; passwd
    for package in readline-common dialog apt-utils build-essential \
        sudo wget make cmake file git ; do
        echo "apt install $package..."
        apt install -y "$package"
    done
    }

fix_locale() {
    echo "Fixing locale..."
    apt purge locales -y
    apt install locales -y
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
    dpkg-reconfigure --frontend=noninteractive locales
    update-locale LANG=en_US.UTF-8
    }

createUser() {
    # $username and $defaultShell env variables set by wsl setup script
    echo "Creating user $username..."
    useradd --create-home --user-group --shell /bin/$defaultShell "$username"
    #echo "$username:$pass1" | chpasswd
    #unset pass1 pass2
    echo "Adding $username to sudo group..."
    usermod -aG sudo "$username"
    echo "Adding $username to sudoers..."
    echo "$username  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$username
    USERHOME=/home/$username
    USERCONFIG=$USERHOME/.config; mkdir -p $USERCONFIG
    USERBIN=$USERHOME/.local/bin; mkdir -p $USERBIN
    USERAPPIMAGES=$USERHOME/.local/appiamges; mkdir -p $USERAPPIMAGES
    }

install_starship() {
    echo "Installing Starship..."
    # or brew
    cd 
    sudo -u "$username" sudo \
        curl -fsSL https://starship.rs/install.sh | bash
    }

apt_update_upgrade() {
    echo "apt update..."
    apt update -y
    echo "apt upgrade..."
    apt upgrade -y
    }

#install_todotxt() {
#    TODO look at wsl Debian for correct paths. Will need symlink to Dropbox
#    cd $USERBIN
#    wget -c https://github.com/todotxt/todo.txt-cli/archive/v2.12.0.tar.gz
#    tar -xvf v2.12.0.tar.gz
#    make
#    make install \
#        CONFIG_DIR=$USERCONFIG \
#        INSTALL_DIR=$USERBIN \
#        BASH_COMPLETION=/usr/share/bash-completion/completions
    #}

install_q() {
    echo "Installing q..."
    # or brew
    cd $USERBIN
    wget -c https://github.com/harelba/q/releases/download/2.0.19/q-text-as-data_2.0.19-2_amd64.deb
    dpkg -i q-text-as-data_2.0.19-2_amd64.deb
    }

install_linuxbrew() {
    echo "Installing linuxbrew..."
    cd $USERHOME
    echo "Downloading and running Brew install script..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
    test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
    echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
    echo "brew install hello..."
    brew install hello
    }

installwith_apt() {
    echo "apt install $1"
    sudo -u "$username" sudo apt install -y "$1"
    }

installwith_brew() {
    echo "brew install $1"
    sudo -u "$username" brew install "$1"
    }

install_mainloop() {
    progsfile="https://raw.githubusercontent.com/pcmariani/scripts/main/progs.csv"
    curl -Ls "$progsfile" | sed '/^#/d' > /tmp/progs.csv
    while IFS=, read -r program method comment; do
        case "$method" in
            "brew")
                echo "Installing brew packages..."
                installwith_brew "$program" "$comment"
                ;;
            *)
                echo "Installing apt packages..."
                installwith_apt "$program" "$comment" 
                ;;
        esac
    done < /tmp/progs.csv
    }

install_neovim() {
    echo "Installing Neovim nightly..."
    mkdir -p $USERAPPIMAGES
    cd $USERAPPIMAGES
    echo "Downloading nvim.appimage..."
    sudo -u $Username sudo \
        curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage 
    echo "Extracting nvim.appimage..."
    ./nvim.appimage --appimage-extract
    NVIMHOME=$USERAPPIMAGES/nvim-nightly/squashfs-root/usr/bin/
    chmod u+x $NVIMHOME/nvim
    cd $USERBIN
    ln -s $NVIMHOME/nvim nvim
    }

#neovim_vimplug() {
    #sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    #   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    #nvim --headless +PlugInstall +qall
    #}

#install_dotfiles() { ;}


main() {
    #clear
    #colorscheme
    #log_init
    #welcome
    #inputUserName
    #inputUserPass

    #h1 'Starting setup...'
    #addSources
    debian_prereqs
    fix_locale
    createUser
    install_starship
    apt_update_upgrade
    install_q
    install_mainloop
    install_neovim

    h1 "\n...done"
    }

main

# vim: fdm=indent fdls=1 fdn=1
