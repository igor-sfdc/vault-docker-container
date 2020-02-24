#!/bin/bash
echo
if [ -z "$1" ]; then
    echo "	ERROR: No container name provided."
    echo "	Usage: remove_existing_image.sh <container-name>"
    echo
    return
fi

container_name=$1
vault_container_id=$(docker container ls -a | grep $container_name | echo $(awk '{print $1}'))

if [ -z "$vault_container_id" ]; then
    echo "No existing vault container found..."
    echo
    return
fi
echo "Removing existing vault docker image: $vault_container_id"
echo "	Stopping container: $(docker container stop $vault_container_id)"
echo "	Removing image: $(docker container rm $vault_container_id)"
echo "	Deleting data... $(rm -rf vault/data/*)"
echo
