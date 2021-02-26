#!/bin/sh

logging=

# Utility functions
colorscheme() {
    reset="$(tput sgr0)$(tput setaf 253)" #grey
    title="$(tput setaf 214)" #orange
    question="$(tput setaf 45)" #darker cyan
    answer="$(tput bold)$(tput setaf 255)" #white
    success="$(tput setaf 2)" #green
    failed="$(tput setaf 1)" #red
}

log_init() {
    logfile=./install-debian-testing.log
    [ "$logging" ] && log "INFO" "Starting install..." > $logfile
}

log() {
    [ "$logging" ] && printf "$(date +"%T") $1 $2 $3\n" | sed 's/\s*$//' >> $logfile
}

say() { 
    printf "$@"
    logitem=$(printf "$@" | sed 's/\.\{3\}\s*$//')
}

yell() {
    printf "${title}$@${reset}\n\n"
}

try() {
    if logmessage=$(eval "$@" 2>&1) ; then
        printf "${success}success${reset}\n"
        log "INFO" "${logitem}...success"
    else
        printf "${logmessage} ${failed}...failed${reset}\n\n"
        log "ERROR" "${logitem}" "${logmessage} ...failed\n"
    fi
}

# Intro
welcome() {
    yell "Welcome to setup of $(head -n1 /etc/os-release | sed 's/PRETTY_NAME=//')"
    printf "  Kernel: $(uname -r)\n"
    printf "  Machine name:  $(uname -n)\n"
    printf "  Processor type: $(uname -p)\n\n"
    read -p "  ${question}Continue(y/n)? ${answer}" yn
    [ "$yn" = "n" ] && printf "\n${failed}Aborting.${reset}\n\n" && exit 1 || printf "${reset}\n"
}

inputUserName() {
    yell 'Create User'
    read -p "${question}  Username: ${answer}" username; printf "${reset}"
}

inputUserPass() {
    printf "${question}  Password: "; stty -echo; read pass1; stty echo; printf "${reset}\n"
    printf "${question}  Re-enter Password: "; stty -echo; read pass2; stty echo; printf "${reset}\n\n"
    if ! [ "$pass1" = "$pass2" ]; then
        printf "  ${failed}Passwords do not match. Try again:${reset}\n\n"
        unset pass1 pass2
        inputUserPass
    fi
}

# Setup
startSetup() {
    yell 'Starting setup...'
}

addSources() {
    say "Adding sources..."
    try printf "hello yall"
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

    say "Updating apt...\n"
    try apt update
}

install_sudo() {
    say "Installing sudo..."
    try echo hello wold #sudo apt install sudo
    #build-essential make apt-utils file curl wget git 
}

createUser() {
    say "Creating user..."
    ## 1st method: useradd - issue that password is exposed
    #try 'useradd --create-home --user-group --shell /bin/bash "$username"'
    #say "Changing password..."
    #try 'echo "$username:$pass1" | chpasswd'
    try echo "$username:$pass1"
    ## 2nd method: adduser
    ##adduser --disabled-password --shell /bin/bash --gecos "" username
    #say "Unsetting password..."
    #try unset pass1 pass2
}

addToSudoers() {
    say "Adding user to sudoers..."
    try echo hello world

    #usermod -aG sudo "$username"
    #su - username
}

install_apt() {
    say "Installing Apt Packages..."
}

install_curl() { ;}

install_git() { ;}

install_homebrew() { ;}

install_dotfiles() { ;}

endSetup() {
    yell "\n...done"
}

clear
colorscheme
log_init
welcome
inputUserName
inputUserPass
startSetup
addSources
install_sudo
createUser
addToSudoers
endSetup


# vim: fdm=indent fdls=1 fdn=1
