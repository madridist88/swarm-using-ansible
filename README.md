# Install Docker Swarm using Ansible

These instructions will allow anyone to deploy a Docker Swarm cluster onto an abitrary number of VMs

<!-- TOC -->

- [Prerequisites](#prerequisites)
- [Boostrapping destination VMs for Ansible](#boostrapping-destination-vms-for-ansible)
- [Deploying Swarm](#deploying-swarm)

<!-- /TOC -->

## Prerequisites

1. VMs to provision Swarm cluster have already been provisioned an accessible.
2. Ansible has been installed on the machine which will be used to run the playbook.
3. Ansible module `atosatto.docker-swarm` has been installed from Ansible Galaxy

   ```sh
   ansible-galaxy install atosatto.docker-swarm
   ```

## Boostrapping destination VMs for Ansible

Ansible connects to VMs using SFTP or SSH protocol for deployments. So for a one-click and no human intervention deployments to a VM, some setup is required.

- Install Python >3.5.
- For security and audit, a separate user account with proper sudoers rights should be used.
- For one-click deployment, password-less authentication needs to be set up between the machine running Ansible playbook and VMs.

Script `bootstrap/setup.sh`, when run on each VM will setup the forementioned requirements.

To bootstrap VMs **for each VM**, perform following steps:

1. Login to VM as `root` user.
2. Copy `bootstrap/setup.sh` to any location on the VM, say `/tmp`.
3. **IMPORTANT:** Edit the script `bootstrap/setup.sh` and change the `publicKey` variable so that it has the public key of machine from where ansible playbook will be executed (usually user's laptop/desktop).
4. Make the script runnable

   ```sh
   chmod u+x /tmp/setup.sh
   ```

5. Execute script to boostrap the VM.

## Deploying Swarm

1. Prepare the Ansible inventory including all the hosts which will be part of Swarm cluster.
2. Group up the hosts into `docker_swarm_manager` and `docker_swarm_worker`. Number of manager hosts must be 1, 3, 5 or 7. For Swarm's high-availability values >=3 are suggested.
3. Run the Ansible playbook

   ```sh
   export ANSIBLE_REMOTE_USER=ansible
   ansible-playbook -i playbook/inventory playbook/deploy-swarm.yml
   ```