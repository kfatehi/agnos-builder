#!/bin/bash
roimgtag=agnos-builder
rwimgtag=agnos-builder-rw
if ! docker images | grep -q $rwimgtag; then
  if ! docker images | grep -q $roimgtag; then
    echo "you need to build the system first to get docker image $roimgtag" 1>&2
    exit 1;
  fi
  rwimglayerid=$(docker history agnos-builder | grep 'tmptmp' | grep 0B | awk '{print$1}')
  docker tag $rwimglayerid $rwimgtag
fi

ubtarball=../ubuntu-base-20.04.1-base-arm64.tar.gz
if [[ ! -d enable-apt ]]; then
  if [[ ! -f $ubtarball ]]; then
    echo "you need to build the system first to get $utarball" 1>&2
    exit 1;
  fi
  mkdir enable-apt
  tar -C ./enable-apt -zxf $ubtarball {etc,var/lib}/apt
fi
docker build -f Dockerfile.weston -t weston-builder .
if [[ ! -d weston-builder-fs ]]; then
  if [[ ! -f weston-builder-fs.tar ]]; then
    CONTAINER_ID=$(docker container create --entrypoint /bin/bash weston-builder)
    docker container export -o weston-builder-fs.tar $CONTAINER_ID
    docker container rm $CONTAINER_ID > /dev/null
  fi
  mkdir weston-builder-fs
  cd weston-builder-fs
  tar -xvf ../weston-builder-fs.tar weston-prefix
fi
