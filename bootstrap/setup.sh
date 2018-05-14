#!/usr/bin/env bash

set -eu -o pipefail

main(){
    ensureGroup
    ensureUser
    addAuthorizedPublicKey
    ensurePython
}

say(){
    local colour="${1:?Colour not provided}"; shift
    local level="${1:?Level not provided}"; shift
    local text="$@"

    echo "${!colour}[ $level ] ${NO_COLOUR} $text"
}

info(){
    say GREEN INFO "$@"
}

warn(){
    say YELLOW WARNING "$@"
}

err(){
    saw RED ERROR "$@"
}

ensureGroup(){
    if [ -z $(grep "^${ANSIBLE_GROUP_NAME}" /etc/group ) ]; then
        groupadd --gid ${ANSIBLE_GROUP_ID} ${ANSIBLE_GROUP_NAME}
        info "Created group: ${ANSIBLE_GROUP_NAME}."
    else
        warn "Group ${ANSIBLE_GROUP_NAME} already exists. Noting to do."
    fi
}

# Create User and adds it to sudoers group
ensureUser(){
    if [ -z $(grep "^${ANSIBLE_USER_NAME}" /etc/passwd ) ]; then
        useradd --gid ${ANSIBLE_GROUP_ID} --uid ${ANSIBLE_USER_ID} --groups sudo ${ANSIBLE_USER_NAME}
        info "Created user: ${ANSIBLE_USER_NAME}."
    else
        warn "User ${ANSIBLE_USER_NAME} already exists. Noting to do."
    fi
}

# Add public key to authorized keys
addAuthorizedPublicKey(){
    local publicKey="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvb7oAigUAxPJ0+oMEqxFf1pv2Jo3p7x50RuKkkI5zdJ170vqfQB6SzmCBlTl75lyT3Xune2u3uIF0sAomRPDeQYbVfGU8T2jl3JoZ4kr1YH26B0KlmZbU85P70a+kdFDs9/brj3MHPIWWSEi9BaL/T6cGni4HWAL7+ElCjqbGLh9MRoHwsxKb/BAQOU80Ea9mQp/A8h445h8KcMLFC3UhHKNYJFevrrBF6weH5K2y15BLB0yWDjiTX2v94R7coW1oj5ofLdgh2GJcwgB2diYw2jSC0eWTicI9dtuOLYEmMnDpr6Ff4+VRFYQJReuug2U0izLv5w/nT8P45WOVa0m8w== aku105@DELAKU10541878"

    # Covering bases if /home/ansible/.ssh didn't exist
    mkdir -p /home/ansible/.ssh && chmod 700 /home/ansible/.ssh
    touch /home/ansible/.ssh/authorized_keys && chmod 600 /home/ansible/.ssh/authorized_keys

    echo $publicKey >> /home/ansible/.ssh/authorized_keys
    info "Added public key to authorized keys."
}

# Check python
ensurePython(){
    local isPythonPresent="false"
    # Check python2
    if [ -n "$(which python)" ]; then
        local python_version=$(python -V)
        info "$python_version already installed."
        isPythonPresent="true"
    fi
    # Check python3
    if [ -n "$(which python3)" ]; then
        local python_version=$(python3 -V)
        info "$python_version already installed."
        isPythonPresent="true"
    fi

    # Install python3 if not installed
    if [ $isPythonPresent == "false" ]; then
        apt-get update
        apt-get install -y python3
        info "Installation finished."
    fi
}

# Terminal colours
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
NO_COLOUR=$(tput sgr0)

# Init variables for user/group creation
ANSIBLE_GROUP_NAME="ansible"
ANSIBLE_GROUP_ID="1599"
ANSIBLE_USER_NAME="ansible"
ANSIBLE_USER_ID="1599"

main "$@"