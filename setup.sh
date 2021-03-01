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
    #try apt update
#}

install_basics() {
    try umask 022
    # curl already installed by wsl setup script
    try apt install -y readline-common dialog apt-utils build-essential sudo make file wget git

}

fix_local() {
    try apt purge locales
    try apt install locales -y
    try echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
    try dpkg-reconfigure --frontend=noninteractive locales
    try update-locale LANG=en_US.UTF-8
}

apt_update_upgrade() {
    try apt update -y
    try apt upgrade -y
}

createUser() {
    # $username and $defaultShell env variables set by wsl setup script
    try useradd --create-home --user-group --shell /bin/$defaultShell "$username"
    #try echo "$username:$pass1" | chpasswd
    #try unset pass1 pass2
}

addToSudoers() {
    try usermod -aG sudo "$username"
    try echo "$username  ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$username
    #su - username <-don't need
}

#install_apt_pgks() {
#}
#
#install_via_curl() { ;}
#
#install_via_git() { ;}
#
#install_homebrew_pkgs() { ;}
#
#install_dotfiles() { ;}

install_neovim() {
    local NVIM_HOME=$HOME/.local/appimages/nvim-nightly
    try echo $NVIM_HOME
    #try mkdir -p $NVIM_HOME
    #try cd $NVIM_HOME
    #try curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage 
    #try chmod u+x nvim.appimage 
    #try ./nvim.appimage --appimage-extract
    #try ln -s ./squashfs-root/usr/bin/nvim nvim
}

#neovim_vimplug() {
    #try sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    #   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    #try nvim --headless +PlugInstall +qall
#}

main() {
    clear
    colorscheme
    log_init
    #welcome
    #inputUserName
    #inputUserPass

    h1 'Starting setup...'
    #addSources
    fix_local
    install_basics
    apt_update_upgrade
    createUser
    addToSudoers

    #h1 "\nInstalling Neovim..."
    #install_neovim

    h1 "\n...done"
}

main

# vim: fdm=indent fdls=1 fdn=1
