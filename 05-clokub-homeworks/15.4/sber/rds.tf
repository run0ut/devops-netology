################################################################################
# Relational Database Service кластер и основная нода

resource "sbercloud_rds_instance" "main_az1" {
  name                = "n15-master" # минимум 4 символа
  flavor              = "rds.mysql.c6.large.2.ha"
  ha_replication_mode = "async"
  availability_zone   = ["ru-moscow-1a", "ru-moscow-1b"]
  vpc_id              = sbercloud_vpc.n15.id
  subnet_id           = sbercloud_vpc_subnet.private.id
  security_group_id   = sbercloud_networking_secgroup.n15.id

  db {
    type     = "MySQL"
    version  = "8.0"
    password = "Servicemode1_"
    port     = "3306"
  }
  volume {
    type = "ULTRAHIGH"
    size = 50
  }
  backup_strategy {
    start_time = "08:00-09:00"
    keep_days  = 1
  }
}

################################################################################
# Реплики

resource "sbercloud_rds_read_replica_instance" "replica_az2" {
  name                = "n15-replica-1"
  flavor              = "rds.mysql.c6.xlarge.2.rr"
  primary_instance_id = sbercloud_rds_instance.main_az1.id
  availability_zone   = "ru-moscow-1b"
  volume {
    type = "ULTRAHIGH"
  }
}

resource "sbercloud_rds_read_replica_instance" "replica_az3" {
  name                = "n15-replica-2"
  flavor              = "rds.mysql.c6.xlarge.2.rr"
  primary_instance_id = sbercloud_rds_instance.main_az1.id
  availability_zone   = "ru-moscow-1c"
  volume {
    type = "ULTRAHIGH"
  }
}

################################################################################
# https://doc.hcs.huawei.com/api/dds/dds_error_code.html описание кодов ошибок
# которые может вернуть облако при создании RDS
