```bash
docker run --rm -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:1234' -p 1234:1234 vault
```

```bash
docker run --rm --cap-add=IPC_LOCK -e 'VAULT_LOCAL_CONFIG={"listener":{"tcp":{"address":"0.0.0.0:8200","tls_disable":1}},"storage":{"file":{"path":"/tmp/foobar"}},"ui":true}' -p 8200:8200 vault server
```

https://www.vaultproject.io/docs/commands#examples

```bash
export VAULT_ADDR="http://127.0.0.1:8200"
vault operator init -address="http://127.0.0.1:8200" -key-shares=1 -key-threshold=1
vault operator unseal
vault login
```

```console
/ # vault operator init -address="http://127.0.0.1:8200" -key-shares=1 -key-threshold=1
Unseal Key 1: kANlkqyUcQax+H8zZsDRJ0lRZFofq7s4Hiv6UEWgRBE=

Initial Root Token: hvs.UdQkeWJdI5uEL30IbyB9EqPI

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated root key. Without at least 1 keys to
reconstruct the root key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.

```
```bash
vault secrets enable -path=secret kv-v2
vault auth enable approle
vault auth list

vault write auth/approle/role/module \
    secret_id_ttl=1h \
    token_ttl=1h \
    token_max_ttl=2h \
    policies="module" \
    bind_secret_id=false
```
```bash
vault kv put secret/module application="Netology 14.2/2" user="sergey" password="111password111"
vault kv get secret/module
```
```bash
vault policy write module - <<EOF
path "secret/data/module" {
  capabilities = ["read"]
}
EOF
```
```
vault read auth/approle/role/module/role-id

/ # vault read auth/approle/role/module/role-id
Key        Value
---        -----
role_id    07607268-e31c-a759-49e1-fe918895f818
```

vault write -f auth/approle/role/module/secret-id

/ # vault write -f auth/approle/role/module/secret-id
Key                   Value
---                   -----
secret_id             658fa890-1419-fd75-093a-5395ac07e599
secret_id_accessor    80d07a16-1193-f2e5-3c0e-6263088d3dba
secret_id_ttl         1h

curl --request POST --data '{"role_id":"07607268-e31c-a759-49e1-fe918895f818"}' http://vault:8200/v1/auth/approle/login --insecure | jq
curl --request POST --data '{"jwt": "'$TOKEN'", "role": "application"}' http://vault:8200/v1/auth/kubernetes/login