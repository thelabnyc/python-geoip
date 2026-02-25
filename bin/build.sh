#!/usr/bin/env bash
set -euxo pipefail

IMAGE="${CI_REGISTRY_IMAGE}:${IMMUTABLE_TAG_NAME}${TAG_SUFFIX}-${ARCH}"
IMAGE_GEOSPATIAL="${CI_REGISTRY_IMAGE}:${IMMUTABLE_TAG_NAME}-geospatial${TAG_SUFFIX}-${ARCH}"

# Build standard image
docker build \
    --pull \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    --tag "$IMAGE" \
    .

# Build geospatial image
docker build \
    --pull \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    --build-arg "GEOSPATIAL=true" \
    --tag "$IMAGE_GEOSPATIAL" \
    .

# Push only on default branch
if [ "${CI_COMMIT_BRANCH:-}" == "${CI_DEFAULT_BRANCH:-}" ]; then
    docker push "$IMAGE"
    docker push "$IMAGE_GEOSPATIAL"
fi
