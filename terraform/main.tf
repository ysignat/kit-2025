resource "yandex_compute_instance" "vm" {
  for_each    = local.vms
  name        = each.key
  hostname    = each.key
  platform_id = "standard-v2"
  zone        = each.value.zone
  folder_id   = local.folder
  labels      = {}

  resources {
    cores  = 2
    memory = 2
    gpus   = 0
  }

  boot_disk {
    initialize_params {
      image_id   = data.yandex_compute_image.ubuntu.image_id
      block_size = 4096
      size       = 20
      type       = "network-ssd"
    }
    mode = "READ_WRITE"
  }

  network_interface {
    index              = 0
    subnet_id          = each.value.subnet
    ipv6               = false
    nat                = true
    security_group_ids = []
  }

  metadata = {
    user-data = file(each.value.metadata_path)
  }

  scheduling_policy {
    preemptible = true
  }

  placement_policy {
    host_affinity_rules       = []
    placement_group_partition = 0
  }

  metadata_options {
    aws_v1_http_endpoint = 1
    aws_v1_http_token    = 2
    gce_http_endpoint    = 1
    gce_http_token       = 1
  }
}
