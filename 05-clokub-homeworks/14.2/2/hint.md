```bash
docker run --rm -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:1234' -p 1234:1234 vault
```

```bash
docker run --rm --cap-add=IPC_LOCK -e 'VAULT_LOCAL_CONFIG={"listener":{"tcp":{"address":"0.0.0.0:8200","tls_disable":1}},"storage":{"file":{"path":"/tmp/foobar"}},"ui":true}' -p 8200:8200 vault server
```

https://www.vaultproject.io/docs/commands#examples

```bash
kubectl exec -it vault-0 -- sh
export VAULT_ADDR="http://127.0.0.1:8200"
vault operator init -key-shares=1 -key-threshold=1 | grep -e 'Unseal Key' -e 'Initial Root Token'
vault operator unseal
vault login
```

```console
/ # vault operator init -address="http://127.0.0.1:8200" -key-shares=1 -key-threshold=1
Unseal Key 1: XcZKRtIEBsSpeaIyv5ZTMmue10lrBZWRpIKlw6Fyyh4=

Initial Root Token: hvs.MguO0nSJDMjUEwUttLCZaiRO

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated root key. Without at least 1 keys to
reconstruct the root key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.

/ # vault operator init -key-shares=1 -key-threshold=1 | grep -e 'Unseal Key' -e 'Initial Root Token'
Unseal Key 1: PbIe8g5JNz6td1x+lGWPWcttBBI2L0kcnv1lL4SnQ10=
Initial Root Token: hvs.lgQQfivJMQ2xZAqZcEK1f0wA

```
```bash
vault secrets enable -path=secret kv-v2
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
vault auth enable approle
vault write auth/approle/role/module \
    secret_id_ttl=1h \
    token_ttl=1h \
    token_max_ttl=2h \
    policies="module" \
    bind_secret_id=false \
    secret_id_bound_cidrs="0.0.0.0/0"
vault auth list
```
```
vault read auth/approle/role/module/role-id

/ # vault read auth/approle/role/module/role-id
Key        Value
---        -----
role_id    4a240cbd-e7c7-08e4-7ca3-7ed0f8d01040
```
```
curl --request POST --data '{"role_id":"07607268-e31c-a759-49e1-fe918895f818"}' http://vault:8200/v1/auth/approle/login --insecure | jq
```