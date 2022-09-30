################################################################################
# Деплоймент с phpMyAdmin

resource "local_file" "deployment" {
  content         = <<EOF
---
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: pma
  name: pma
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pma
  # strategy:
  #   type: Recreate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: pma
    spec:
      containers:
      - image: phpmyadmin
        name: phpmyadmin
        ports:
        - containerPort: 80
        env:
        - name: PMA_USER
          value: "root"
        - name: PMA_PASSWORD 
          value: "${sbercloud_rds_instance.main_az1.db[0].password}"
        - name: PMA_HOST
          value: "${sbercloud_rds_instance.main_az1.private_ips[0]}"
EOF
  filename        = "manifests/00-deployment.yml"
  file_permission = "0644"
}

################################################################################
# Service для балансировщика с публичным IP

resource "local_file" "service" {
  content         = <<EOF
---
apiVersion: v1
kind: Service
metadata:
  name: pma-service
spec:
  type: LoadBalancer
  loadBalancerIP: ${sbercloud_vpc_eip.lb.address}
  selector:
    app: pma
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
EOF
  filename        = "manifests/10-service.yml"
  file_permission = "0644"
}

################################################################################
# Конфиг kubectl
# WARNING!!! Заменит существующий файл, если есть. Только для тестовой среды!

resource "local_sensitive_file" "kube_config" {
  content  = sbercloud_cce_cluster.n15.kube_config_raw
  filename = pathexpand("~/.kube/config")
  # filename        = "kubeconfig.json"
  file_permission = "0644"
}