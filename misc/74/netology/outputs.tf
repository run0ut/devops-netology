output "aws_metadata_account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS account ID"
}

output "aws_metadata_user_id" {
  value       = data.aws_caller_identity.current.user_id
  description = "AWS user ID"
}

output "aws_metadata_region" {
  value       = data.aws_region.current.endpoint
  description = "AWS регион, который используется в данный момен"
}

output "aws_net_private_ip" {
  value       = resource.aws_instance.ubuntu_count.*.private_ip
  description = "Приватный IP ec2 инстанса, созданного с count"
}

output "aws_net_subnet_id" {
  value       = resource.aws_instance.ubuntu_count.*.subnet_id
  description = "Идентификатор подсети инстанса, созданного с count"
}

output "aws_net_private_ip__for_each" {
  value = toset([
    for instance in aws_instance.ubuntu_for_each : instance.private_ip
  ])
  description = "Приватный IP ec2 инстанса, созданного с for_each"
}

output "aws_net_subnet_id__for_each" {
  value = toset([
    for instance in aws_instance.ubuntu_for_each : instance.subnet_id
  ])
  description = "Идентификатор подсети инстанса, созданного с for_each"
}
