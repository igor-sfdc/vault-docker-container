#!/usr/bin/env bash

container_name="$(basename $PWD)_vault_1"
echo "Container name: " $container_name

# Remove the existing Vault Docker image, if any:
. ./remove_existing_image.sh $container_name

# Build new Vault Docker image:
docker-compose up -d --build

# Initialize and unseal Vault:
docker exec $container_name  vault operator init>init-output.txt
docker exec $container_name vault operator unseal \
    $(grep 'Key 1:' init-output.txt | awk '{print $NF}')
docker exec $container_name vault operator unseal \
    $(grep 'Key 2:' init-output.txt | awk '{print $NF}')
docker exec $container_name vault operator unseal \
    $(grep 'Key 3:' init-output.txt | awk '{print $NF}')

# Export root token to the host shell:
export VAULT_TOKEN=$(grep 'Initial Root Token:' init-output.txt | awk '{print $NF}')

# Login:
docker exec $container_name \
    vault login $VAULT_TOKEN

# Enable v2 engine:
docker exec $container_name \
    vault secrets enable -version=2 kv

# Test write/read operations:
docker exec $container_name \
curl \
     -H "X-Vault-Token: $VAULT_TOKEN" \
     -H "Content-Type: application/json" \
     -X POST \
     -d '{ "data": { "foo": "world" } }' \
     http://127.0.0.1:8200/v1/kv/data/hello

docker exec $container_name \
curl \
     -H "X-Vault-Token: $VAULT_TOKEN" \
     -X GET \
     http://127.0.0.1:8200/v1/kv/data/hello

echo
echo 'Finished creating Vault container.'
echo 'Root token: ' $VAULT_TOKEN
echo
