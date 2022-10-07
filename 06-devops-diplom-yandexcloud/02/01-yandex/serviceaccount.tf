// Create SA
resource "yandex_iam_service_account" "diploma" {
  folder_id = var.yandex_folder_id
  name      = "diploma-${terraform.workspace}"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "viewer" {
  folder_id = var.yandex_folder_id
  role      = "viewer"
  member    = "serviceAccount:${yandex_iam_service_account.diploma.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.yandex_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.diploma.id}"
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "diploma" {
  service_account_id = yandex_iam_service_account.diploma.id
  description        = "static access key for object storage"
}