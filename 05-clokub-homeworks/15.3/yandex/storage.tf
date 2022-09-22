resource "yandex_storage_bucket" "secure_bucket" {
  bucket     = "n15-encrypted"
  access_key = yandex_iam_service_account_static_access_key.n15.access_key
  secret_key = yandex_iam_service_account_static_access_key.n15.secret_key

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.n15.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "yandex_storage_bucket" "web_bucket" {
  bucket     = "n15.run0ut.ru"
  access_key = yandex_iam_service_account_static_access_key.n15.access_key
  secret_key = yandex_iam_service_account_static_access_key.n15.secret_key

  anonymous_access_flags {
    read = true
    list = true
  }
}

resource "yandex_storage_object" "netology-logo-encrypted" {
  bucket     = yandex_storage_bucket.secure_bucket.bucket
  key        = "netology-logo.png"
  source     = "../../15.1/yandex/netology-logo.png"
  access_key = yandex_iam_service_account_static_access_key.n15.access_key
  secret_key = yandex_iam_service_account_static_access_key.n15.secret_key
  acl        = "public-read"
}

resource "yandex_storage_object" "netology-logo" {
  bucket     = yandex_storage_bucket.web_bucket.bucket
  key        = "netology-logo.png"
  source     = "../../15.1/yandex/netology-logo.png"
  access_key = yandex_iam_service_account_static_access_key.n15.access_key
  secret_key = yandex_iam_service_account_static_access_key.n15.secret_key
  acl        = "public-read"
}

resource "yandex_storage_object" "indexpage" {
  bucket     = yandex_storage_bucket.web_bucket.bucket
  key        = "index.html"
  source     = "index.html"
  access_key = yandex_iam_service_account_static_access_key.n15.access_key
  secret_key = yandex_iam_service_account_static_access_key.n15.secret_key
  acl        = "public-read"
}

