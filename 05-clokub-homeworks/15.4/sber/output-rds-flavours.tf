# ################################################################################
# # РАСКОМЕНТИРУЙТЕ, ЧТОБЫ ИСПОЛЬЗОВАТЬ
# ################################################################################

# ###############################################################################
# # Узнать доступные тарифы RDS

# data "sbercloud_rds_flavors" "master" {
#   db_type       = "MySQL"
#   db_version    = "8.0"
#   instance_mode = "ha"
# }

# data "sbercloud_rds_flavors" "replica" {
#   db_type       = "MySQL"
#   db_version    = "8.0"
#   instance_mode = "replica"
# }

# output "MySQL_master_flavours" {
#   value = [
#     for f in data.sbercloud_rds_flavors.master.flavors:
#       "${f.name}, CPU: ${f.vcpus}, RAM: ${f.memory}"
#   ]
# }

# output "MySQL_replica_flavours" {
#   value = [
#     for f in data.sbercloud_rds_flavors.replica.flavors:
#       "${f.name}, CPU: ${f.vcpus}, RAM: ${f.memory}"
#   ]
# }

# ###############################################################################
# # Тарифы, доступные на 29.09.2022
# #
# # Changes to Outputs:
# #   + MySQL_master_flavours  = [
# #       + "rds.mysql.c6.16xlarge.2.ha, CPU: 64, RAM: 128",
# #       + "rds.mysql.c6.large.2.ha, CPU: 2, RAM: 4",
# #       + "rds.mysql.c6.2xlarge.4.ha, CPU: 8, RAM: 32",
# #       + "rds.mysql.c6.4xlarge.2.ha, CPU: 16, RAM: 32",
# #       + "rds.mysql.c6.xlarge.2.ha, CPU: 4, RAM: 8",
# #       + "rds.mysql.c6.8xlarge.2.ha, CPU: 32, RAM: 64",
# #       + "rds.mysql.c6.2xlarge.2.ha, CPU: 8, RAM: 16",
# #       + "rds.mysql.c6.xlarge.4.ha, CPU: 4, RAM: 16",
# #       + "rds.mysql.c6.large.4.ha, CPU: 2, RAM: 8",
# #       + "rds.mysql.c2.4xlarge.ha, CPU: 16, RAM: 32",
# #       + "rds.mysql.c2.medium.ha, CPU: 1, RAM: 2",
# #       + "rds.mysql.s1.medium.ha, CPU: 1, RAM: 4",
# #       + "rds.mysql.c2.2xlarge.ha, CPU: 8, RAM: 16",
# #       + "rds.mysql.c2.large.ha, CPU: 2, RAM: 4",
# #       + "rds.mysql.c2.8xlarge.ha, CPU: 32, RAM: 64",
# #     ]
# #   + MySQL_replica_flavours = [
# #       + "rds.mysql.c6.xlarge.4.rr, CPU: 4, RAM: 16",
# #       + "rds.mysql.c2.2xlarge.rr, CPU: 8, RAM: 16",
# #       + "rds.mysql.c2.8xlarge.rr, CPU: 32, RAM: 64",
# #       + "rds.mysql.c6.2xlarge.4.rr, CPU: 8, RAM: 32",
# #       + "rds.mysql.c2.medium.rr, CPU: 1, RAM: 2",
# #       + "rds.mysql.c6.xlarge.2.rr, CPU: 4, RAM: 8",
# #       + "rds.mysql.c6.16xlarge.2.rr, CPU: 64, RAM: 128",
# #       + "rds.mysql.c6.4xlarge.2.rr, CPU: 16, RAM: 32",
# #       + "rds.mysql.c6.large.4.rr, CPU: 2, RAM: 8",
# #       + "rds.mysql.c6.large.2.rr, CPU: 2, RAM: 4",
# #       + "rds.mysql.s1.medium.rr, CPU: 1, RAM: 4",
# #       + "rds.mysql.c2.4xlarge.rr, CPU: 16, RAM: 32",
# #       + "rds.mysql.c2.large.rr, CPU: 2, RAM: 4",
# #       + "rds.mysql.c6.8xlarge.2.rr, CPU: 32, RAM: 64",
# #       + "rds.mysql.c6.2xlarge.2.rr, CPU: 8, RAM: 16",
# #     ]