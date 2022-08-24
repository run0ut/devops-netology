import hvac

# Kubernetes (from k8s pod)
client = hvac.Client(
    url='http://vault:8200'
)

client.auth.approle.login(
    role_id='07607268-e31c-a759-49e1-fe918895f818',
    # secret_id='658fa890-1419-fd75-093a-5395ac07e599'
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


print(secret['data']['data'])

