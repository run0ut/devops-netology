resource "sbercloud_kms_key" "n15-1" {
  key_alias       = "n15-1"
  pending_days    = "7"
  key_description = "Netology DevOps, h/w 15.3"
  is_enabled      = true
}