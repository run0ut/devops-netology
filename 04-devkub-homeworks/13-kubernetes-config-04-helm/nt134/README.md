# Запуск

Приложения по-умолчанию используют PersistentVolume с динамическим провиженером на NFS-сервере. В параметрах запуска нужно укахать хост и папку NFS-сервера:
```console
helm dependency build
helm install nt134 . --set nfs-subdir-external-provisioner.server=10.0.0.1, nfs-subdir-external-provisioner.path: /mnt/myshareddir
```
Если персистентность нен ужна, то запускать надо так:
```console
helm dependency build
helm install nt134 . --set global.persistence.enabled=false
```
