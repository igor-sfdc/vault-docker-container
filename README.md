Useful links:
See tutorial here (at the bottom): https://learn.hashicorp.com/vault/operations/ops-generate-root
Creating docker image: https://www.bogotobogo.com/DevOps/Docker/Docker-Vault-Consul.php

Run the following commands to test:

docker-compose up -d --build

docker exec vault-docker-root_vault_1  vault operator init>init-output.txt
docker exec vault-docker-root_vault_1 vault operator unseal \
    $(grep 'Key 1:' init-output.txt | awk '{print $NF}')
docker exec vault-docker-root_vault_1 vault operator unseal \
    $(grep 'Key 2:' init-output.txt | awk '{print $NF}')
docker exec vault-docker-root_vault_1 vault operator unseal \
    $(grep 'Key 3:' init-output.txt | awk '{print $NF}')

# Export root token to the host
export VAULT_TOKEN=$(grep 'Initial Root Token:' init-output.txt | awk '{print $NF}')

docker exec vault-docker-root_vault_1 \
apk add curl

docker exec vault-docker-root_vault_1 \
curl \
     -H "X-Vault-Token: $VAULT_TOKEN" \
     -H "Content-Type: application/json" \
     -X POST \
     -d '{ "data": { "foo": "world" } }' \
     http://127.0.0.1:8200/v1/secret/data/hello

docker exec vault-docker-root_vault_1 \
curl \
     -H "X-Vault-Token: $VAULT_TOKEN" \
     -X GET \
     http://127.0.0.1:8200/v1/secret/data/hello

