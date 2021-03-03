#!/bin/sh

#   <~-- - -~<o>~- - --~>
#
#   Debian WSL setup
#
#   <~-- - -~<o>~- - --~>


eecho() {
    echo "${green}$@${reset}"
    }

colors() {
    green="$(tput setaf 2)"
    reset="$(tput sgr0)"
    }

debian_prereqs() {
    umask 022
    echo "Set root password:"; passwd
    for package in readline-common dialog apt-utils build-essential \
        sudo wget make cmake file git ; do
        eecho "apt install $package..."
        apt install -y "$package"
    done
    }

fix_locale() {
    eecho "Fixing locale..."
    apt purge locales -y
    apt install locales -y
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
    dpkg-reconfigure --frontend=noninteractive locales
    update-locale LANG=en_US.UTF-8
    }

create_user() {
    # $username and $defaultShell env variables set by wsl setup script
    eecho "Creating user $username..."
    useradd --create-home --user-group --shell /bin/$defaultShell "$username"
    #echo "$username:$pass1" | chpasswd
    #unset pass1 pass2
    eecho "Adding $username to sudo group..."
    usermod -aG sudo "$username"
    eecho "Adding $username to sudoers..."
    echo "$username  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$username
    #sudo -k # clear sudo password cache
    }

apt_update_upgrade() {
    eecho "apt update..."
    apt update -y
    eecho "apt upgrade..."
    apt upgrade -y
    }

continue_as_user() {
    eecho "Creating user directories..." 
    USERHOME=/home/$username
    USERCONFIG=$USERHOME/.config; mkdir -p $USERCONFIG
    USERBIN=$USERHOME/.local/bin; mkdir -p $USERBIN
    USERAPPIMAGES=$USERHOME/.local/appiamges; mkdir -p $USERAPPIMAGES
    eecho "Changing user to $username..." 
    su $username
    cd $USERHOME
    echo "Set password for $username:"; passwd
}

install_linuxbrew() {
    eecho "Installing linuxbrew..."
    eecho "Downloading and running Brew install script..."
    # cause the script to run non-interactively by piping from echo
    echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    #test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
    test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
    echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
    eecho "brew install hello..."
    brew install hello
    }

install_packages() {
    progsfile="https://raw.githubusercontent.com/pcmariani/scripts/main/progs.csv"
    curl -Ls "$progsfile" | sed '/^#/d' > /tmp/progs.csv
    while IFS=, read -r package method comment; do
        case "$method" in
            "brew")
                eecho "brew install $package"
                brew install "$package"
                ;;
            *)
                eecho "apt install $package"
                sudo apt install -y "$package"
                ;;
        esac
    done < /tmp/progs.csv
    }

install_neovim() {
    cd $USERAPPIMAGES
    eecho "Downloading neovim-nightly..."
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage 
    eecho "Extracting nvim.appimage..."
    ./nvim.appimage --appimage-extract
    NVIMHOME=$USERAPPIMAGES/nvim-nightly/squashfs-root/usr/bin/
    chmod u+x $NVIMHOME/nvim
    cd $USERBIN
    eecho "Creating simlink in bin..."
    ln -s $NVIMHOME/nvim nvim
    cd $USERHOME
    }

install_dotfiles() {
    dotfiles_setup_script="https://raw.githubusercontent.com/pcmariani/scripts/main/setup-dotfiles.sh"
    curl -Ls "$dotfiles_setup_script" | sed '/^#/d' > /tmp/setup-dotfiles.sh
    /bin/bash -c /tmp/setup-dotfiles.sh
    }

install_vimplug() {
    eecho "Downloading vim-plug..."
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    eecho "Installing plugins..."
    nvim --headless +PlugInstall +qall
    }

finalize() {
    eecho "Exiting back to root..."
    exit
    eecho "Done Debian WSL setup"
}

#   <~-- - -~<o>~- - --~>   #

main() {
    colors
    debian_prereqs
    fix_locale
    create_user
    apt_update_upgrade
    continue_as_user
    install_linuxbrew
    install_packages
    install_neovim
    install_dotfiles
    install_vimplug
    finalize
    }

main

#   <~-- - -~<o>~- - --~>   #


#clear
#log_init
#welcome
#inputUserName
#inputUserPass
#h1 'Starting setup...'
#addSources

#reset="$(tput sgr0)$(tput setaf 253)" #grey
#green="$(tput setaf 214)" #orange
#question="$(tput setaf 81)" #darker cyan
#answer="$(tput bold)$(tput setaf 255)" #white
#success="$(tput setaf 2)" #green
#failed="$(tput setaf 1)" #red
#stderr="$(tput setaf 175)" #white

## Script core {{{
#log_init() {
#    logfile=./install-debian-testing.log
#    [ "$logging" ] && log "INFO Starting install..." > $logfile
#}
#
#log() {
#    [ "$logging" ] && printf "$(date +"%T") $@\n" >> $logfile
#}
#
#h1() {
#    printf "${green}$@${reset}\n\n${reset}"
#}
#
#p() {
#    printf "${reset}$@\n"
#}
#
#try() { 
#    #tput sc
#    #printf "${reset}[       ] ${*}..."
#    printf "${*} ..."
#    if eval_result=$(eval "$@" 2>&1) ; then
#        #stty -echo; tput rc; tput cuf 1; stty echo
#        #printf "${success}success${reset}\n" 
#        [ "$verbose" ] && p "${eval_result}\n"
#    else
#        #stty -echo; tput rc; tput cuf 1; stty echo
#        printf "${failed}failed${reset}"
#        printf "${stderr}${eval_result}\n"
#        log "ERROR ${*} ${eval_result} ...failed\n"
#    fi
#}
## }}}
#
## Intro {{{
#welcome() {
#    h1 "Welcome to setup of $(head -n1 /etc/os-release | sed 's/PRETTY_NAME=//')"
#    p "  Kernel: $(uname -r)"
#    p "  Machine name:  $(uname -n)"
#    p "  Processor type: $(uname -p)\n"
#    read -p "  ${question}Continue(y/n)? ${answer}" yn
#    [ "$yn" = "n" ] && printf "\n${failed}Aborting.${reset}\n\n" && exit 1 || p
#}
#
#inputUserName() {
#    h1 'Create User'
#    read -p "${question}  Username: ${answer}" username; printf "${reset}"
#}
#
#inputUserPass() {
#    printf "${question}  Password: "; stty -echo; read pass1; stty echo; p
#    printf "${question}  Re-enter Password: "; stty -echo; read pass2; stty echo; p "\n"
#    if ! [ "$pass1" = "$pass2" ]; then
#        printf "  ${failed}Passwords do not match. Try again:${reset}\n\n"
#        unset pass1 pass2
#        inputUserPass
#    fi
#}
## }}}

#addSources() {
    #echo " \
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

#install_starship() {
#    eecho "Installing Starship..."
#    # or brew
#    sudo -u "$username" sudo \
#        curl -fsSL https://starship.rs/install.sh | bash
#    }
#
#install_q() {
#    eecho "Installing q..."
#    # or brew
#    pushd $USERBIN
#    wget -c https://github.com/harelba/q/releases/download/2.0.19/q-text-as-data_2.0.19-2_amd64.deb
#    dpkg -i q-text-as-data_2.0.19-2_amd64.deb
#    popd
#}

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


# vim: fdm=indent fdls=1 fdn=1
