# Docker Vault container example

This will remove the existing vault-docker-container_vault_1 container, if any, and recreate it:

```
git clone https://github.com/igor-sfdc/vault-docker-container
cd vault-docker-container
. ./create-vault.sh
```

Executing vault commands from host shel (require login):

```
docker exec vault-docker-container_vault_1 \
    vault kv put kv/my-secret my-value=s3cr3t
docker exec vault-docker-container_vault_1 \
    vault kv get kv/my-secret
```

References:
  
https://learn.hashicorp.com/vault/operations/ops-generate-root

https://www.bogotobogo.com/DevOps/Docker/Docker-Vault-Consul.php
