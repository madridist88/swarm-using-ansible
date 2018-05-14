# Install Docker Swarm using Ansible

These instructions will allow anyone to deploy a Docker Swarm cluster onto an abitrary number of VMs

<!-- TOC -->

- [Prerequisites](#prerequisites)
- [Boostrapping VMs for Ansible](#boostrapping-vms-for-ansible)
- [Deploying Swarm](#deploying-swarm)

<!-- /TOC -->

## Prerequisites

1. VMs to provision Swarm cluster have already been provisioned an accessible.
2. Ansible has been installed on the machine which will be used to run the playbook.
3. Ansible module `atosatto.docker-swarm` has been installed from Ansible Galaxy

   ```sh
   ansible-galaxy install atosatto.docker-swarm
   ```

## Boostrapping VMs for Ansible

Ansible connects to VMs using SFTP or SSH protocol for deployments. So for a one-click and no human intervention deployments to a VM, some setup is required.

- Install Python >3.5.
- For security and audit, a separate user account with proper sudoers rights should be used.
- For one-click deployment, password-less authentication needs to be set up between the machine running Ansible playbook and VMs.

Script `bootstrap/setup.sh`, when run on each VM will setup the forementioned requirements.

## Deploying Swarm

1. Prepare the Ansible inventory including all the hosts which will be part of Swarm cluster.
2. Group up the hosts into `docker_swarm_manager` and `docker_swarm_worker`. Number of manager hosts must be 1, 3, 5 or 7. For Swarm's high-availability values >3 are suggested.
3. Run the Ansible playbook

   ```sh
   ansible-playbook -i playbook/inventory playbook/deploy-swarm.sh
   ```