#!/bin/sh

red="$(tput setaf 1)"
green="$(tput setaf 2)"
yellow="$(tput setaf 3)"
blue="$(tput setaf 4)"
magenta="$(tput setaf 5)"
cyan="$(tput setaf 6)"
white="$(tput bold)$(tput setaf 255)"
orange="$(tput setaf 180)"
grey="$(tput setaf 253)"
normal=$(tput sgr0)

reset="$(tput sgr0)"$grey
title=$green
question=$cyan
answer=$white
good=$green
bad=$red

success="${good}success!${reset}\n"

intro() {
    printf "${title}Welcome to setup of "; head -n1 /etc/os-release | sed "s/PRETTY_NAME=//"
    printf "\n${reset}"
    printf "  Kernel: "; uname -r
    printf "  Machine name: "; uname -n
    printf "  Processor type: "; uname -p
    printf "\n"
    read -p "  ${question}Continue(y/n)? ${answer}" start
    if [ "$start" = "n" ] ; then
        printf "\n${bad}Aborting.${reset}\n\n"
        exit 0
    fi
}

createUserName() {
    printf "${title}Create User\n\n"
    read -p "${question}  Username: ${answer}" name
}

createUserPass() {
    printf "${question}  Password: ${answer}"; stty -echo; read pass1; stty echo; printf "\n"
    printf "${question}  Re-enter Password: ${answer}"; stty -echo; read pass2; stty echo; printf "${reset}\n"

    if ! [ "$pass1" = "$pass2" ]; then
        printf "\n  ${bad}Passwords do not match. Try again:${reset}\n\n"
        unset pass1 pass2
        createUserPass
    else
        #clear
        printf "\n\n"
        printf "${good}User created successfully.${reset} "
    fi
}

startSetup() {
    printf "${title}Starting setup...${reset}\n\n"
}

addSources() {
    printf "Adding sources to /etc/apt/sources.list..."

    #printf "\
    #deb http://deb.debian.org/debian/ testing main
    #deb-src http://deb.debian.org/debian/ testing main
    #
    #deb http://deb.debian.org/debian/ testing-updates main
    #deb-src http://deb.debian.org/debian/ testing-updates main
    #
    #deb http://deb.debian.org/debian-security testing-security main
    #deb-src http://deb.debian.org/debian-security testing-security main
    #" > /etc/apt/sources.list
    printf $success

    printf "updtating apt..."
    #apt update
    printf $success
}

endSetup() {
    printf "\ndone.\n"
}

clear
intro
#clear
printf "\n\n"
createUserName
createUserPass
startSetup
addSources
endSetup
