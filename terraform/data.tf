data "yandex_vpc_subnet" "default-ru-central1-a" {
  name = "default-ru-central1-a"
}

data "yandex_vpc_subnet" "default-ru-central1-b" {
  name = "default-ru-central1-b"
}

data "yandex_vpc_subnet" "default-ru-central1-d" {
  name = "default-ru-central1-d"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}
