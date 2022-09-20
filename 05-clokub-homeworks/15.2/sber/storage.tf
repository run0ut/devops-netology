# Бакет
resource "sbercloud_obs_bucket" "n15" {
  bucket = "n15"
  acl    = "public-read"
}

# Объект (картинка)
resource "sbercloud_obs_bucket_object" "netology-logo" {
  bucket       = sbercloud_obs_bucket.n15.bucket
  key          = "netology-logo.png"
  source       = "../yandex/netology-logo.png"
  content_type = "image/png"
  acl          = "public-read"
}