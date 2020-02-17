Useful links:
  
See tutorial here (at the bottom): https://learn.hashicorp.com/vault/operations/ops-generate-root

Creating docker image: https://www.bogotobogo.com/DevOps/Docker/Docker-Vault-Consul.php

Run the following commands to test:

```
# Remove the existing container, if any, otherwise ignore errors:
docker container ls -a | grep 'vault-docker-container_vault_1'  | docker container stop $(awk '{print $1}') | docker container rm $(awk '{print $1}')
rm -rf vault/data/*

# Build new container
docker-compose up -d --build

# Unseal vault
docker exec vault-docker-container_vault_1  vault operator init>init-output.txt
docker exec vault-docker-container_vault_1 vault operator unseal \
    $(grep 'Key 1:' init-output.txt | awk '{print $NF}')
docker exec vault-docker-container_vault_1 vault operator unseal \
    $(grep 'Key 2:' init-output.txt | awk '{print $NF}')
docker exec vault-docker-container_vault_1 vault operator unseal \
    $(grep 'Key 3:' init-output.txt | awk '{print $NF}')

# Export root token to the host:
export VAULT_TOKEN=$(grep 'Initial Root Token:' init-output.txt | awk '{print $NF}')

# Login
docker exec vault-docker-container_vault_1 \
    vault login $VAULT_TOKEN

# Upgrade to v2
docker exec vault-docker-container_vault_1 \
    vault secrets enable -version=2 kv

# Write test value
docker exec vault-docker-container_vault_1 \
    curl \
         -H "X-Vault-Token: $VAULT_TOKEN" \
         -H "Content-Type: application/json" \
         -X POST \
         -d '{ "data": { "foo": "world" } }' \
         http://127.0.0.1:8200/v1/secret/data/hello

# Read test value
docker exec vault-docker-container_vault_1 \
    curl \
         -H "X-Vault-Token: $VAULT_TOKEN" \
         -X GET \
         http://127.0.0.1:8200/v1/secret/data/hello

echo 'Root token: ' $VAULT_TOKEN
```

Or simply run:

```
. create-vault.sh
```

Other useful commands (require login):

```
# Execute vault put and get commands directly:
docker exec vault-docker-container_vault_1 \
    vault kv put secret/my-secret my-value=s3cr3t
docker exec vault-docker-container_vault_1 \
    vault kv get secret/my-secret
```

