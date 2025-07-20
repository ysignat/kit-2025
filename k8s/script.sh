#!/usr/bin/env sh

yc compute instance create \
  --name k8s-testing \
  --hostname k8s-testing \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=container-optimized-image,size=20GB,type=network-ssd \
  --cores 4 \
  --memory 8GB \
  --core-fraction 100 \
  --preemptible \
  --metadata-from-file user-data=cloud-init-k8s.yml