resource "yandex_mdb_mysql_cluster" "n15" {
  name        = "n15-1"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.network.id
  version     = "8.0"
  deletion_protection = false

  resources {
    resource_preset_id = "b1.medium" # https://cloud.yandex.com/en-ru/docs/managed-mysql/concepts/instance-types
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  backup_window_start {
    hours = 23
    minutes = 59
  }

  maintenance_window {
    type = "ANYTIME"
  }

  mysql_config = {
    sql_mode                      = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    max_connections               = 100
    default_authentication_plugin = "MYSQL_NATIVE_PASSWORD"
    innodb_print_all_deadlocks    = true

  }

  host {
    zone      = yandex_vpc_subnet.zoneA.zone
    subnet_id = yandex_vpc_subnet.zoneA.id
  }

  host {
    zone      = yandex_vpc_subnet.zoneB.zone
    subnet_id = yandex_vpc_subnet.zoneB.id
  }

  host {
    zone      = yandex_vpc_subnet.zoneC.zone
    subnet_id = yandex_vpc_subnet.zoneC.id
  }
}

resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster.n15.id
  name       = "netology_db"
}

resource "yandex_mdb_mysql_user" "netology" {
    cluster_id = yandex_mdb_mysql_cluster.n15.id
    name       = "netology"
    password   = "servicemode"

    permission {
      database_name = yandex_mdb_mysql_database.netology_db.name
      roles         = ["ALL"]
    }

    connection_limits {
      max_questions_per_hour   = 10
      max_updates_per_hour     = 20
      max_connections_per_hour = 30
      max_user_connections     = 40
    }

    global_permissions = ["PROCESS"]

    authentication_plugin = "SHA256_PASSWORD"
}