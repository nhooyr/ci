#!/bin/sh
set -eu

docker build -t nhooyr/ci:latest ./ci/image

if [ "${CI-}" ] && echo "${GITHUB_REF-}" | grep -q "master$"; then
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
  docker push nhooyr/ci:latest
fi
