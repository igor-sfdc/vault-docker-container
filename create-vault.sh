#!/usr/bin/env bash

# Remove the existing container, if any, otherwise ignore errors:
docker container ls -a | grep 'vault-docker-container_vault_1'  | docker container stop $(awk '{print $1}') | docker container rm $(awk '{print $1}')
rm -rf vault/data/*

docker-compose up -d --build

docker exec vault-docker-container_vault_1  vault operator init>init-output.txt
docker exec vault-docker-container_vault_1 vault operator unseal \
    $(grep 'Key 1:' init-output.txt | awk '{print $NF}')
docker exec vault-docker-container_vault_1 vault operator unseal \
    $(grep 'Key 2:' init-output.txt | awk '{print $NF}')
docker exec vault-docker-container_vault_1 vault operator unseal \
    $(grep 'Key 3:' init-output.txt | awk '{print $NF}')

# Export root token to the host:
export VAULT_TOKEN=$(grep 'Initial Root Token:' init-output.txt | awk '{print $NF}')

docker exec vault-docker-container_vault_1 \
    vault login $VAULT_TOKEN

docker exec vault-docker-container_vault_1 \
    vault secrets enable -version=2 kv

docker exec vault-docker-container_vault_1 \
curl \
     -H "X-Vault-Token: $VAULT_TOKEN" \
     -H "Content-Type: application/json" \
     -X POST \
     -d '{ "data": { "foo": "world" } }' \
     http://127.0.0.1:8200/v1/secret/data/hello

docker exec vault-docker-container_vault_1 \
curl \
     -H "X-Vault-Token: $VAULT_TOKEN" \
     -X GET \
     http://127.0.0.1:8200/v1/secret/data/hello

echo 'Root token: ' $VAULT_TOKEN

