```bash
docker run --rm -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:1234' -p 1234:1234 vault
```

```bash
docker run --rm --cap-add=IPC_LOCK -e 'VAULT_LOCAL_CONFIG={"listener":{"tcp":{"address":"0.0.0.0:8200","tls_disable":1}},"storage":{"file":{"path":"/tmp/foobar"}},"ui":true}' -p 8200:8200 vault server
```

https://www.vaultproject.io/docs/commands#examples

```console
/ # vault operator init -address="http://127.0.0.1:8200" -key-shares=1 -key-threshold=1
Unseal Key 1: EfUZ1NDIIGbnjbIX/74sLluFM0eb7G6iFY86Q5a4YjE=

Initial Root Token: hvs.u9A2Kzo1sH514xjD6IzFrSCv

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
export VAULT_ADDR="http://127.0.0.1:8200"
vault operator unseal
vault login
```

```bash
vault secrets enable -path=secret kv-v2
vault auth enable approle
vault auth list

vault write auth/approle/role/my-role \
    secret_id_ttl=1h \
    token_ttl=1h \
    token_max_ttl=2h
```
```bash
vault kv put secret/module application="Newtology 14.2/2" user="sergey" password="111password111"
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
vault read auth/approle/role/my-role/role-id

/ # vault read auth/approle/role/my-role/role-id
Key        Value
---        -----
role_id    709dc70d-1ace-b13b-47a2-e20c5b1563db
```

vault write -f auth/approle/role/my-role/secret-id

/ # vault write -f auth/approle/role/my-role/secret-id
Key                   Value
---                   -----
secret_id             e88e81db-f57a-5ab7-26f3-b89a71b88a8a
secret_id_accessor    aa023dcd-d4ec-3c53-7b1b-cb8e37d49e39
secret_id_ttl         1h

curl --request POST --data '{"role_id":"1ead29bc-1b64-a7b6-e7db-a3e01ceb75aa"}' http://vault:8200/v1/auth/approle/login --insecure | jq
curl --request POST --data '{"jwt": "'$TOKEN'", "role": "application"}' http://vault:8200/v1/auth/kubernetes/login