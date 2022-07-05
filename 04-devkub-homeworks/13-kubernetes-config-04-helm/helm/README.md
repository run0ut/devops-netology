# Запуск

Установите зависимости и запустите приложение:
```console
helm dependency build
helm install nt134 . 
```
Можно добавить PersistentVolume на NFS-сервере. В параметрах запуска нужно указать хост и папку NFS-сервера, а так же включить персистентность:
```console
helm dependency build
helm install nt134 . --set nfs-client.server=10.0.0.1, nfs-client.path: /mnt/myshareddir --set global.persistence.enabled=true
```
При этом будут созданы неуникальные Pod, StorageClass и PersistenVolumeClaim для провиженера, но тогда установить одновременно две версии приложения в один неймспейс не получится.