#!/bin/bash
set -e
VERSION="$(git describe)"
docker build -t griff/sparklelog:$VERSION .
docker tag griff/sparklelog:$VERSION griff/sparklelog:latest

docker run griff/xellia-profile:$VERSION tar zc -C app . > sparklelog.tar.gz