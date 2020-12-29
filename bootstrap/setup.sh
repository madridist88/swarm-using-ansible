#!/usr/bin/env bash

set -eu -o pipefail

publicKey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLRMO/3Dch56bykYc+L+DLdieOyJU9jGoMJb+41t4/yB8DfYiaVKcVO4Nbf8d0cxD9W2MJPWFKgYTj+ytW9UZ5Dqrj5kK/D93lvYw4t+Ul26iKjZVcPBA1acGcfEo40g7rHeiEQ3SjrdXqBscbfNdg+abLgwINj1YTFYDY7CtPxc6XDJRB6GkVMg2Ssj2GLhiNaBLNpxdalMwXVpO/BcIBqDK8Qp2uZnGXeDydpN77E1vPH/PVLwv+vkKS+2Ys70FkJRtweEgLsQJVMqfV1Tq7dwmJkShl14b4BPe5ZTvi7hzBDHHRp8umMhwF1k1BORLmIM54zURvDCJY/U+cZV/yyehp2uW/vNLcN+PomBlfAKKDAfm2oBWjPTqLwmUInbhLAETLsu2PD0vyqjbeD62a6qYxq7grfXNeuBh0HQLtIxGR6KXcBFncsfJDRzL5aRFIZkD5OSyQ1nskMIrJW/AkmvbjerhbU8QCIRCLFr9U5UrfXINa+f+2iiF1ptcLYqpXiZQiLuU/t5JwFtSfY4GWY1edC6CRU7yhQdfbOsbMLBETK7xvuMxzMHwOrq8k+noBqatwdsbkuqXnyT5uv3iQNPBpE7RZYEYglPAFbI7x4mZAte3wV2l5mFGhdo4SIYCOEIQO5MMydSaLBzGiVWLJNNRSL31yHgeVUf0wAzjutQ== ao@rusatom.dev"

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
    # Covering bases if /home/ansible/.ssh didn't exist
    mkdir -p /home/ansible/.ssh && chmod 700 /home/ansible/.ssh
    touch /home/ansible/.ssh/authorized_keys && \
      chmod 600 /home/ansible/.ssh/authorized_keys && \
      chown -R ansible.ansible /home/ansible/

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

    # Install python2 if not installed
    if [ $isPythonPresent == "false" ]; then
        apt-get update
        apt-get install -y python
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
