### mysql

```bash
wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" --output-document ./mysql/root.crt && chmod 0600 ./mysql/root.crt
```

```bash
mysql --host=rc1a-dqudab5qdf2yb8kv.mdb.yandexcloud.net \
      --port=3306 \
      --ssl-ca=./mysql/root.crt \
      --ssl-mode=VERIFY_IDENTITY \
      --user=netology \
      --password \
      netology_db
```

### k8s

```bash
yc managed-kubernetes cluster \
  get-credentials n15 \
  --external --force
```