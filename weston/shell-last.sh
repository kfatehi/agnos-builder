#!/bin/bash
lastimg=$(docker images | head -n2 | tail -n1 | awk '{print $3}')

docker run --rm -it $lastimg bash
