resource "yandex_iam_service_account" "sa_terraform" {
  name        = "sa-terraform"
  description = "Для развертывания с помощью Terraform"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = "${yandex_resourcemanager_folder.my_folder}"
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.sa_terraform.id}",
  ]
  depends_on = [
    yandex_iam_service_account.sa_terraform,
  ]
}

