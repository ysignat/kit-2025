#!/usr/bin/env sh

yc compute instance create \
  --name webserver-testing-02 \
  --hostname webserver-testing-02 \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2004-lts,size=20GB,type=network-ssd \
  --cores 2 \
  --memory 2GB \
  --core-fraction 100 \
  --preemptible \
  --metadata-from-file user-data=cloud-init-minion.yml \
  --labels 'ansible_python_interpreter=/usr/bin/python3.8,ansible_ssh_private_key_file=.ssh/ansible.ed25519,ansible_user=yc-user,nginx_version=1.28.0'
