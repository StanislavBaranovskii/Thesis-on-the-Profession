resource "yandex_resourcemanager_cloud" "my_cloud" {}

resource "yandex_resourcemanager_folder" "my_folder" {
  cloud_id    = "yandex_resourcemanager_cloud.my_cloud.id"
  name        = "thesis-on-the-profession"
  description = "Проект дипломной работы"
}

