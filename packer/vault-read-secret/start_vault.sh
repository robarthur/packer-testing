#!/usr/bin/env bash

docker_id=$(docker run -d --cap-add=IPC_LOCK -p 8200:8200 -e VAULT_ADDR='http://127.0.0.1:8200' vault server -dev)
docker_exec="docker exec ${docker_id}"
# Wait for docker to start and become available
sleep 5
vault_root_token=$(docker logs ${docker_id} 2>&1 | egrep "$Root Token" | cut -f2 -d":" | xargs)

eval "${docker_exec} /bin/sh -c 'echo ${vault_root_token} > ~/.vault-token'"
eval "${docker_exec} /bin/sh -c 'cat ~/.vault-token'" > .vault-token
eval "${docker_exec} vault secrets enable -version=2 kv"

private_key=$(cat deploy_key_example)
#eval "${docker_exec} vault secrets enable -version=2 kv"
#sleep 3
eval "${docker_exec} vault kv put secret/deploykey private=\"${private_key}\""