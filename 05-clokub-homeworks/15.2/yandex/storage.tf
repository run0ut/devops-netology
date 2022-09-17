resource "yandex_storage_bucket" "bucket" {
  bucket     = "n15-bucket"
  access_key = yandex_iam_service_account_static_access_key.n15.access_key
  secret_key = yandex_iam_service_account_static_access_key.n15.secret_key
}

resource "yandex_storage_object" "netology-logo" {
  bucket     = yandex_storage_bucket.bucket.bucket
  key        = "netology-logo.png"
  source     = "netology-logo.png"
  access_key = yandex_iam_service_account_static_access_key.n15.access_key
  secret_key = yandex_iam_service_account_static_access_key.n15.secret_key
  acl        = "public-read"
}