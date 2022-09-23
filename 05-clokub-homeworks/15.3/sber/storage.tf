# Бакет
resource "sbercloud_obs_bucket" "n15" {
  bucket = "n15"
  acl    = "public-read"
  encryption = false
}

# Бакет
resource "sbercloud_obs_bucket" "n15-encrypted" {
  bucket = "n15-encrypted"
  acl    = "public-read"
  encryption = true
  kms_key_id = sbercloud_kms_key.n15-1.id
}

# Объект (картинка)
resource "sbercloud_obs_bucket_object" "netology-logo" {
  bucket       = sbercloud_obs_bucket.n15.bucket
  key          = "netology-logo.png"
  source       = "../../15.2/yandex/netology-logo.png"
  content_type = "image/png"
  acl          = "public-read"
}

# Объект (картинка)
resource "sbercloud_obs_bucket_object" "netology-logo-enc" {
  bucket       = sbercloud_obs_bucket.n15-encrypted.bucket
  key          = "netology-logo.png"
  source       = "../../15.2/yandex/netology-logo.png"
  content_type = "image/png"
  acl          = "public-read"
}