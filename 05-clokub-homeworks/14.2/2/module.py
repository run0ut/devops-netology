import hvac

# Kubernetes (from k8s pod)
client = hvac.Client(
    url='http://vault:8200'
)

client.auth.approle.login(
    role_id='709dc70d-1ace-b13b-47a2-e20c5b1563db',
    secret_id='e88e81db-f57a-5ab7-26f3-b89a71b88a8a',
)

# client.is_authenticated()

# Пишем секрет
# client.secrets.kv.v2.create_or_update_secret(
#     path='hvac',
#     secret=dict(netology='Big secret!!!'),
# )

# Читаем секрет
secret = client.secrets.kv.v2.read_secret_version(
    path='module',
)


print(secret)

