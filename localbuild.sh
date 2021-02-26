#!/bin/bash
RADON="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 9 | head -n 1)"
DOCKER_IMAGE='httpinjector:latest'
docker pull $(cat Dockerfile|grep FROM|sed 's|FROM ||g') 
docker build . --tag ${DOCKER_IMAGE} && {
    echo "Run: docker run -ti -e ADMIN_USERNAME=\"teste\" -e ADMIN_PASSWORD=\"$RADON\" -p 22:22/tcp -p 80:80/tcp -p 8080:8080/tcp -p 443:443/tcp 554:554/tcp -p 1935:1935/tcp -p 7070:7070/tcp -p 8000:8000/tcp -p 8001:8001/tcp -p 6971-6999:6971-6999/tcp $DOCKER_IMAGE"
    echo "Run: docker run -ti $DOCKER_IMAGE"
    if [[ -e /tmp/buildandrun ]];then
        docker run -ti --rm $DOCKER_IMAGE
    fi
}
exit 0