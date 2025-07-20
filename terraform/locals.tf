locals {
  folder = "b1gd9grok106is5l1uuj"
  vms = {
    webserver-testing-01 = {
      metadata_path = "../cloud-init-master.yml"
      zone          = "ru-central1-d"
      subnet        = data.yandex_vpc_subnet.default-ru-central1-d.subnet_id
    }
    webserver-testing-02 = {
      metadata_path = "../cloud-init-minion.yml"
      zone          = "ru-central1-a"
      subnet        = data.yandex_vpc_subnet.default-ru-central1-a.subnet_id
    }
    webserver-testing-03 = {
      metadata_path = "../cloud-init-minion.yml"
      zone          = "ru-central1-b"
      subnet        = data.yandex_vpc_subnet.default-ru-central1-b.subnet_id
    }
  }
}
