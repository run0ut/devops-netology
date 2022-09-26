wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" --output-document ./mysql/root.crt && chmod 0600 ./mysql/root.crt


mysql --host=rc1a-egbsp3l8qvg2br8j.mdb.yandexcloud.net \
      --port=3306 \
      --ssl-ca=./mysql/root.crt \
      --ssl-mode=VERIFY_IDENTITY \
      --user=netology \
      --password \
      netology_db

